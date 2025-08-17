//
//  MusicPlayerViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 8/17/25.
//

import Foundation

protocol MusicPlayerViewModelInput {
}

// MARK: - Output
protocol MusicPlayerViewModelOutput {

}

// MARK: - ViewModel
protocol MusicPlayerViewModel: MusicPlayerViewModelInput, MusicPlayerViewModelOutput,
    ObservableObject
{}

// MARK: - Implementation
final class DefaultFMusicPlayerViewModel: MusicPlayerViewModel {
    
}
