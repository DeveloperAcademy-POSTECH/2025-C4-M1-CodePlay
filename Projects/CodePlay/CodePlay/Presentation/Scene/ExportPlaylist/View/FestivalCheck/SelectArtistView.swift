//
//  SelectArtistView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI
import SwiftData
import MusicKit

struct SelectArtistView: View {
    @Environment(\.dismiss) var dismiss
    let playlist: Playlist
    @State private var artistArtworks: [String: URL?] = [:]
    @State private var failedArtists: Set<String> = []
    @State private var selectedArtists: Set<String> = []
    @State private var isNextActive = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            
            VStack(alignment: .center){
                Spacer().frame(height: 16)

                festivalInfoBox
                
                Spacer().frame(height: 24)
                
                HStack (alignment : .center ){
                    Text("플레이리스트에 추가")
                        .font(.BlgRegular())
                        .foregroundColor(.neu900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        if selectedArtists.count < playlist.artists.count {
                            selectedArtists = Set(playlist.artists)
                        } else {
                            selectedArtists.removeAll()
                        }
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: selectedArtists.count < playlist.artists.count ? .regular : .bold))
                                .foregroundColor(selectedArtists.count < playlist.artists.count ? .neu700 : Color("Primary"))
                            Text("전체선택")
                                .font(selectedArtists.count < playlist.artists.count ? .BmdRegular() : .BmdBold())
                                .foregroundColor(selectedArtists.count < playlist.artists.count ? .neu700 : Color("Primary"))
                        }
                    }
                }
      
                ArtistGridView
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            BottomButton(title: "선택 완료", kind: .colorFill) {
                isNextActive = true
            }
            .disabled(selectedArtists.isEmpty)
            .padding(.bottom, 50)
            .padding(.horizontal, 14)
            .padding(.top, 15)
            .liquidGlass(style: .listbutton)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal){
                Text("아티스트 선택")
                    .font(.BlgBold())
                    .foregroundColor(.neu900)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.neu900)
                    }
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                    },
                    label: {
                        Text("취소")
                            .font(.BlgRegular())
                            .foregroundColor(.neu900)
                    }
                )
            }

        }
        .onAppear {
            fetchArtistArtworks()
        }
        .navigationDestination(isPresented: $isNextActive) {
            ExportPlaylistView(
                selectedArtists: Array(selectedArtists),
                playlist: playlist
            )
        }
    }
    
    @ViewBuilder
    private var festivalInfoBox: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.HmdBold())
                    .foregroundColor(.neu900)
                    .lineSpacing(28)
                    
                Text(playlist.place ?? "")
                    .font(.BsmRegular())
                    .foregroundColor(Color.neu700)
                    .lineSpacing(16)
                
                Text(playlist.period ?? "")
                    .font(.BsmRegular())
                    .foregroundColor(Color.neu700)
                    .lineSpacing(16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
        .shadow(color: .neu900.opacity(0.1), radius: 10, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.neu50.opacity(0.9), lineWidth: 2)
            
        )
        .background(.neu50.opacity(0.3))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var ArtistGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(playlist.artists, id: \.self) { artist in
                    VStack(spacing: 8) {
                        ZStack {
                            AsyncImage(url: artistArtworks[artist] ?? nil) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 110, height: 110)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(selectedArtists.contains(artist) ? Color("Primary") : Color.neutral50, lineWidth : 4)
                                            )
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 110)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onTapGesture {
                            toggleSelection(for: artist)
                        }
                        
                        Text(artist.prefix(10))
                            .font(.BmdRegular())
                            .foregroundColor(failedArtists.contains(artist) ? .neu700 : .neu900)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 126)
        }
    }
    
    private func toggleSelection(for artist: String) {
        if selectedArtists.contains(artist) {
            selectedArtists.remove(artist)
        } else {
            selectedArtists.insert(artist)
        }
    }
    
    private func fetchArtistArtworks() {
        Task {
            for artist in playlist.artists {
                do {
                    var request = MusicCatalogSearchRequest(term: artist, types: [Artist.self])
                    request.limit = 1
                    let response = try await request.response()
                    if let firstArtist = response.artists.first {
                        let artworkURL = firstArtist.artwork?.url(width: 112, height: 112)
                        DispatchQueue.main.async {
                            artistArtworks[artist] = artworkURL
                        }
                    } else {
                        DispatchQueue.main.async {
                            artistArtworks[artist] = nil
                            failedArtists.insert(artist)
                        }
                    }
                } catch {
                    print("Error fetching artwork for \(artist): \(error)")
                    DispatchQueue.main.async {
                        artistArtworks[artist] = nil
                        failedArtists.insert(artist)
                    }
                }
            }
        }
    }
}

//#Preview {
//    let mockPlaylist = Playlist(
//        id: UUID(),
//        title: "Mock Festival",
//        createdAt: .now,
//        period: "2025.08.15 - 08.17",
//        cast: "TAEYANG, NEWJEANS, G-DRAGON, JAY PARK, LISA, THE BOYZ, ATEEZ, ZICO, LE SSERAFIM",
//        festivalId: nil,
//        place: "Seoul"
//    )
//    SelectArtistView(playlist: mockPlaylist)
//}
