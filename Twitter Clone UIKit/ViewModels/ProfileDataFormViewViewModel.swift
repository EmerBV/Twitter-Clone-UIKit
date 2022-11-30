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
    
    @Published var url: URL?
    @Published var error: String = ""
    
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
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] url in
                self?.url = url
            }
            .store(in: &subscriptions)
    }
}
