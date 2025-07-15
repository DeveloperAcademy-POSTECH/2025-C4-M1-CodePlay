//
//  LicenseCheckView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI

struct LicenseCheckView: View {
    @State var isNavigateToFetchFestival = false
    
    var body: some View {
        NavigationStack{
            Button(action: {
                isNavigateToFetchFestival = true
                print("버튼 눌림")
            }, label: {
                Text("페스티벌 리스트 페이지 이동")
            })
            
            NavigationLink(destination: FetchFestivalView(), isActive: $isNavigateToFetchFestival) {}
                .hidden()
        }
    }
}

#Preview {
    LicenseCheckView()
}
