//
//  ProfileViewViewModel.swift
//  Twitter Clone UIKit
//
//  Created by Emerson Balahan Varona on 30/11/22.
//

import Foundation
import Combine
import FirebaseAuth

final class ProfileViewViewModel: ObservableObject {
    @Published var user: TwitterUser?
    @Published var error: String?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // Función para recuperar los datos del usuario en la view controller
    func retreiveUser() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: id)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)
    }
}
