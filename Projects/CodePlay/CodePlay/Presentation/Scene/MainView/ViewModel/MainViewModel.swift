//
//  MainViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation

// MARK: MainViewModelInput
protocol MainViewModelInput {
    
}

// MARK: MainViewModelOutput
protocol MainViewModelOutput {
    
}

// MARK: MainViewModel
protocol MainViewModel: MainViewModelInput, MainViewModelOutput { }

// MARK: DefaultMainViewModel
final class DefaultMainViewModel: MainViewModel {
    
}

