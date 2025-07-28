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
        ZStack(alignment: .leading) {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                Spacer().frame(height: 16)

                festivalInfoBox
                
                Spacer().frame(height: 24)
                
                ArtistGridView
                
                Spacer()
                
                BottomButton(title: "Apple Music으로 전송", kind: .colorFill) {
                    isNextActive = true
                }
                .disabled(selectedArtists.isEmpty)
                .padding(.bottom, 50)
                .padding(.top, 15)
                .liquidGlass(style: .listbutton)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal){
                Text("아티스트 선택")
                    .font(.BlgBold())
                    .foregroundColor(.neu50)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.neu50)
                    }
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                    },
                    label: {
                        Text("취소")
                            .foregroundColor(.neu50)
                    }
                )
            }

        }
        .onAppear {
            fetchArtistArtworks()
        }
        .navigationDestination(isPresented: $isNextActive) {
            ExportPlaylistView(selectedArtists: Array(selectedArtists))
        }
    }
    
    @ViewBuilder
    private var festivalInfoBox: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.HmdBold())
                    .foregroundColor(.black)
                    .lineSpacing(2)
                    
                Text(playlist.place ?? "")
                    .font(.BsmRegular())
                    .foregroundColor(Color.neu700)
                    .lineSpacing(2)
                
                Text(playlist.period ?? "")
                    .font(.BsmRegular())
                    .foregroundColor(Color.neu700)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.9), lineWidth: 2)
            
        )
        .background(.neu50.opacity(0.3))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var ArtistGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(playlist.artists, id: \.self) { artist in
                    VStack(spacing: 8) {
                        ZStack {
                            AsyncImage(url: artistArtworks[artist] ?? nil) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 112, height: 112)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 112, height: 112)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 112, height: 112)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 112, height: 112)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            if selectedArtists.contains(artist) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                                    .background(Color.white.clipShape(Circle()))
                                    .offset(x: 40, y: 40)
                            }
                        }
                        .onTapGesture {
                            toggleSelection(for: artist)
                        }
                        
                        Text(artist.prefix(10))
                            .font(.caption)
                            .foregroundColor(failedArtists.contains(artist) ? .gray : .black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.horizontal, 16)
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
