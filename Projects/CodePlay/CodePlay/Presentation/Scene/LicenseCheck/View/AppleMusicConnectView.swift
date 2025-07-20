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
    let diContainer: MainLicenseDIContainer

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
                    
                    BottomButton(title: "설정으로 이동") {
                        viewModelWrapper.viewModel.shouldOpenSettings.value = true
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                BottomButton(
                    title: "Apple Music에 연결",
                    action: {
                        viewModelWrapper.viewModel
                            .shouldRequestMusicAuthorization.value = true
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

    var viewModel: any AppleMusicConnectViewModel

    init(viewModel: any AppleMusicConnectViewModel) {
        self.viewModel = viewModel

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

