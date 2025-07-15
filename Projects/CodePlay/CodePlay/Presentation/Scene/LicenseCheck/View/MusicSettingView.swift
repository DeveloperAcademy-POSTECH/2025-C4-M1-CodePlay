//
//  MusicSettingView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
import MusicKit
internal import Combine

struct MusicSettingsView: View {
    @ObservedObject var viewModelWrapper: AppleMusicConnectViewModelWrapper
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 상단 여백
                Spacer().frame(height: 20)
                
                // 음악 라이브러리 연결 섹션
                VStack(spacing: 16) {
                    Text("음악 라이브러리 연결")
                        .font(Font.custom("KoddiUD OnGothic", size: 24).weight(.bold))
                        .foregroundColor(.black)
                    
                    Text("앱과 위에서 전체 재생 중인 트랙을 표시할 수 있도록\nCodePlay가 라이브러리에 접근하도록 허용하세요.")
                        .font(Font.custom("KoddiUD OnGothic", size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                }
                
                // 권한 상태 카드
                VStack(spacing: 16) {
                    // 권한 상태
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("권한 상태")
                                .font(Font.custom("KoddiUD OnGothic", size: 16).weight(.medium))
                                .foregroundColor(.black)
                            
                            Text(viewModelWrapper.authorizationStatus?.statusText ?? "확인 중...")
                                .font(Font.custom("KoddiUD OnGothic", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Circle()
                            .fill(viewModelWrapper.authorizationStatus?.isAuthorized == true ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                    
                    // 구독 상태
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("구독 상태")
                                .font(Font.custom("KoddiUD OnGothic", size: 16).weight(.medium))
                                .foregroundColor(.black)
                            
                            Text(viewModelWrapper.subscriptionStatus?.statusText ?? "확인 중...")
                                .font(Font.custom("KoddiUD OnGothic", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if viewModelWrapper.subscriptionStatus?.isChecking == true {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Circle()
                                .fill(viewModelWrapper.subscriptionStatus?.hasActiveSubscription == true ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                
                // 에러 메시지
                if let errorMessage = viewModelWrapper.errorMessage {
                    Text(errorMessage)
                        .font(Font.custom("KoddiUD OnGothic", size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // 버튼들
                VStack(spacing: 12) {
                    // 권한 요청 버튼
                    if viewModelWrapper.authorizationStatus?.isAuthorized != true {
                        Button(action: {
                            viewModelWrapper.viewModel.requestMusicAuthorization()
                        }) {
                            Text("권한 요청")
                                .font(Font.custom("KoddiUD OnGothic", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.37, green: 0.37, blue: 0.37))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // 구독 상태 새로고침 버튼
                    if viewModelWrapper.authorizationStatus?.isAuthorized == true {
                        Button(action: {
                            viewModelWrapper.viewModel.checkMusicSubscription()
                        }) {
                            Text("구독 상태 새로고침")
                                .font(Font.custom("KoddiUD OnGothic", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.37, green: 0.37, blue: 0.37))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .disabled(viewModelWrapper.subscriptionStatus?.isChecking == true)
                    }
                    
                    // Apple Music 구독 버튼
                    if viewModelWrapper.authorizationStatus?.isAuthorized == true &&
                       viewModelWrapper.subscriptionStatus?.hasActiveSubscription != true {
                        Button(action: {
                            viewModelWrapper.viewModel.openAppleMusicSubscription()
                        }) {
                            Text("Apple Music 구독하기")
                                .font(Font.custom("KoddiUD OnGothic", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // 설정 앱으로 이동 버튼
                    if viewModelWrapper.authorizationStatus?.status == .denied {
                        Button(action: {
                            viewModelWrapper.viewModel.openSettings()
                        }) {
                            Text("설정으로 이동")
                                .font(Font.custom("KoddiUD OnGothic", size: 18))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // 하단 여백
                Spacer().frame(height: 40)
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                    .font(Font.custom("KoddiUD OnGothic", size: 16))
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            viewModelWrapper.viewModel.updateMusicAuthorizationStatus()
        }
    }
}
