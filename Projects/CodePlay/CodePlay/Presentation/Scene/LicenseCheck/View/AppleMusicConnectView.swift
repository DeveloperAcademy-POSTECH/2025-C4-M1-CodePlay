//
//  AppleMusicConnectView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
import MusicKit
internal import Combine

struct AppleMusicConnectView: View {
    @ObservedObject var viewModelWrapper: AppleMusicConnectViewModelWrapper
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
                    
                    Button(action: {
                        viewModelWrapper.viewModel.openSettings()
                    }) {
                        Text("설정으로 이동")
                            .font(Font.custom("KoddiUD OnGothic", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.blue)
                            .cornerRadius(999)
                    }
                }
                .padding(.horizontal, 16)
            } else {
                // 권한 요청 버튼
                Button(action: {
                    viewModelWrapper.viewModel.requestMusicAuthorization()
                }) {
                    HStack {
                        Text("Apple Music에 연결")
                            .font(Font.custom("KoddiUD OnGothic", size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.37, green: 0.37, blue: 0.37))
                    .cornerRadius(999)
                }
                .padding(.horizontal, 16) // 좌우 여백
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
        .ignoresSafeArea(.all, edges: .bottom) // 하단 Safe Area 무시
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("설정") {
                    showingSettings = true
                }
                .font(Font.custom("KoddiUD OnGothic", size: 16))
                .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingSettings) {
            MusicSettingsView(viewModelWrapper: viewModelWrapper)
        }
    }
}

// MARK: - ViewModelWrapper for ObservableObject compatibility
final class AppleMusicConnectViewModelWrapper: ObservableObject {
    @Published var authorizationStatus: MusicAuthorizationStatusModel?
    @Published var subscriptionStatus: MusicSubscriptionModel?
    @Published var errorMessage: String?
    @Published var canPlayMusic: Bool = false
    
    var viewModel: any AppleMusicConnectViewModel
    
    init(viewModel: any AppleMusicConnectViewModel) {
        self.viewModel = viewModel
        
        // Observable 바인딩
        viewModel.authorizationStatus.observe(on: self) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }
        
        viewModel.subscriptionStatus.observe(on: self) { [weak self] subscription in
            DispatchQueue.main.async {
                self?.subscriptionStatus = subscription
            }
        }

        viewModel.errorMessage.observe(on: self) { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error
            }
        }

        viewModel.canPlayMusic.observe(on: self) { [weak self] canPlay in
            DispatchQueue.main.async {
                self?.canPlayMusic = canPlay
            }
        }
    }
}
