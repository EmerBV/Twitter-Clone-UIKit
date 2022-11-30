//
//  ProfileDataFormViewViewModel.swift
//  Twitter Clone UIKit
//
//  Created by Emerson Balahan Varona on 12/11/22.
//

import Foundation
import Combine
import UIKit
import FirebaseAuth
import FirebaseStorage

final class ProfileDataFormViewViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    @Published var imageData: UIImage?
    // Esta variable es el que valida si se ha rellenado
    @Published var isFormValid: Bool = false
    
    @Published var error: String = ""
    @Published var isOnboardingFinished: Bool = false
    
    // Esta es la función que usaremos para dar por visto bueno el formulario. Tiene que cumplir todos estos requisitos para que pueda hacerse el submit
    func validateUserProfileForm() {
        guard let displayName = displayName,
              // Para que el campo del displayName sea válido tiene que tener más de dos letras
              displayName.count > 2,
              let username = username,
              username.count > 2,
              let bio = bio,
              bio.count > 2,
              imageData != nil else {
            isFormValid = false
            return
        }
        isFormValid = true
    }
    
    func uploadAvatar() {
        
        let randomID = UUID().uuidString
        guard let imageData = imageData?.jpegData(compressionQuality: 0.5) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // LLamamos a la función que hemos hecho en el StorageManager
        StorageManager.shared.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
            .flatMap({ metaData in
                StorageManager.shared.getDownloadURL(for: metaData.path)
            })
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.error = error.localizedDescription
                case .finished:
                    self?.updateUserData()
                }
            } receiveValue: { [weak self] url in
                                    // Esto hace que se transforme la url en string
                self?.avatarPath = url.absoluteString
            }
            .store(in: &subscriptions)
    }
    
    private func updateUserData() {
        guard let displayName,
              let username,
              let bio,
              let avatarPath,
              let id = Auth.auth().currentUser?.uid else { return }
        
        let updatedFields: [String: Any] = [
            "displayName": displayName,
            "username": username,
            "bio": bio,
            "avatarPath": avatarPath,
            "isUserOnboarded": true
        ]
        
        DatabaseManager.shared.collectionUsers(updateFields: updatedFields, for: id)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] onboardingState in
                self?.isOnboardingFinished = onboardingState
            }
            .store(in: &subscriptions)
    }
}
