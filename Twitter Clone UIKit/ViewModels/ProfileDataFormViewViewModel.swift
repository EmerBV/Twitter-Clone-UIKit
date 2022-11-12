//
//  ProfileDataFormViewViewModel.swift
//  Twitter Clone UIKit
//
//  Created by Emerson Balahan Varona on 12/11/22.
//

import Foundation
import Combine

final class ProfileDataFormViewViewModel: ObservableObject {
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
}
