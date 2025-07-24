//
//  AppleMusicConnectView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

internal import Combine
import MusicKit
import SwiftUI

struct AppleMusicConnectView: View {
    @EnvironmentObject var viewModelWrapper: MusicViewModelWrapper
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 여백 (Safe Area 고려하여 조정)
            Spacer().frame(height: 106)

            ZStack {
                // 이미지 들어갈 자리
                Image(systemName: "music.note")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.gray)
            }
            .frame(width: 280, height: 280)
            .background(Color(red: 0.86, green: 0.86, blue: 0.86))
            .cornerRadius(20)

            // 사각형과 제목 사이 간격
            Spacer().frame(height: 32)

            // 2. 큰 제목 텍스트
            Text("Apple Music을\n연결해주세요")
                .font(Font.custom("KoddiUD OnGothic", size: 30).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            // 제목과 설명 사이 간격
            Spacer().frame(height: 4)

            // 3. 설명 텍스트
            Text("페스티벌 플레이리스트 생성을 위해\nApple Music을 연결해주세요.")
                .font(Font.custom("KoddiUD OnGothic", size: 17))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal, 32)

            // 설명과 버튼 사이 간격
            Spacer()

            // 4. 연결 버튼 또는 설정 안내 (하단에서 적절한 위치에 배치)
            if viewModelWrapper.authorizationStatus?.status == .denied {
                // 권한 거부 시 설정 안내
                VStack(spacing: 16) {
                    Text("설정에서 권한을 허용해주세요")
                        .font(Font.custom("KoddiUD OnGothic", size: 18))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    BottomButton(title: "설정으로 이동", kind: .line) {
                        viewModelWrapper.appleMusicConnectViewModel.shouldOpenSettings.value = true
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                BottomButton(
                    title: "Apple Music에 연결",
                    kind: .line,
                    action: {
                        Task {
                            // 권한 요청
                            viewModelWrapper.appleMusicConnectViewModel   .shouldRequestMusicAuthorization.value = true
                        }
                    }
                )
                .padding(.horizontal, 16)
            }

            // 에러 메시지 표시
            if let errorMessage = viewModelWrapper.errorMessage {
                Text(errorMessage)
                    .font(Font.custom("KoddiUD OnGothic", size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)
            }

            // 하단 여백 (Home Indicator 고려)
            Spacer().frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .bottom)  // 하단 Safe Area 무시
    }
}

// MARK: - ViewModelWrapper for ObservableObject compatibility
final class MusicViewModelWrapper: ObservableObject {
    @Published var authorizationStatus: MusicAuthorizationStatusModel?
    @Published var subscriptionStatus: MusicSubscriptionModel?
    @Published var errorMessage: String?
    @Published var canPlayMusic: Bool = false
    @Published var artistCandidates: [String] = []
    /// 현재 프로세스 단계 (0: 대기, 1: 아티스트 탐색 시작, 2: 아티스트 탐색 완료, 3: 인기곡 추출 완료)
    @Published var progressStep: Int = 0
    /// 플레이리스트 생성 완료 후 MadePlaylistView로의 네비게이션 트리거
    @Published var navigateToMadePlaylist: Bool = false
    /// Apple Music으로 내보내기 중인지 여부
    @Published var isExporting: Bool = false
    /// Apple Music 내보내기 완료 여부
    @Published var isExportCompleted: Bool = false
    /// 완성된 플레이리스트 엔트리 목록
    @Published var playlistEntries: [PlaylistEntry] = []

    var appleMusicConnectViewModel: any AppleMusicConnectViewModel
    var exportViewModelWrapper: any ExportPlaylistViewModel

    init(appleMusicConnectViewModel: any AppleMusicConnectViewModel, exportViewModelWrapper: any ExportPlaylistViewModel) {
        self.appleMusicConnectViewModel = appleMusicConnectViewModel
        self.exportViewModelWrapper = exportViewModelWrapper

        appleMusicConnectViewModel.authorizationStatus.observe(on: self) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                
                if status?.status == .authorized {
                    self?.canPlayMusic = true
                } else {
                    self?.canPlayMusic = false
                }
            }
        }

        appleMusicConnectViewModel.subscriptionStatus.observe(on: self) { [weak self] subscription in
            DispatchQueue.main.async {
                self?.subscriptionStatus = subscription
            }
        }

        appleMusicConnectViewModel.errorMessage.observe(on: self) { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error
            }
        }

        appleMusicConnectViewModel.canPlayMusic.observe(on: self) { [weak self] canPlay in
            DispatchQueue.main.async {
                self?.canPlayMusic = canPlay
                print("[viewModelWrapper]:\(self?.canPlayMusic)")
            }
        }
    }
    /// View가 나타날 때 호출되는 함수
    /// - OCR로부터 받은 RawText를 바탕으로 전체 흐름 수행
    func onAppear(with rawText: RawText?) {
        guard let rawText else { return }

        progressStep = 0

        // 1단계: 텍스트 전처리 (후보 아티스트 추출)
        exportViewModelWrapper.preProcessRawText(rawText)
        progressStep = 1

        Task {
            // 2단계: 아티스트 검색
            let matches = await exportViewModelWrapper.searchArtists(from: rawText)
            DispatchQueue.main.async {
                self.progressStep = 2
                matches.forEach { print("✅ \( $0.artistName ) (\($0.appleMusicId))") }
            }

            // 3단계: 아티스트별 상위 곡 검색
            let songs = await exportViewModelWrapper.searchTopSongs(from: rawText, artistMatches: matches)
            DispatchQueue.main.async {
                self.progressStep = 3
                self.playlistEntries = songs
                for entry in songs {
                    print("🎵 \(entry.artistName) - \(entry.trackTitle)")
                }
                self.navigateToMadePlaylist = true
            }
        }
    }
    
    /// Apple Music으로 플레이리스트를 내보내는 트리거 함수
    func exportToAppleMusic() {
        isExporting = true

        Task {
            await exportViewModelWrapper.exportLatestPlaylistToAppleMusic()

            // 내보내기 완료 후 상태 업데이트 (5초 후 완료 상태 전환)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.isExporting = false
                self.isExportCompleted = true
            }
        }
    }
}

