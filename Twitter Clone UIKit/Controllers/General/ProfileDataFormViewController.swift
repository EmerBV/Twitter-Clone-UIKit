//
//  ProfileDataFormViewController.swift
//  Twitter Clone UIKit
//
//  Created by Emerson Balahan Varona on 12/11/22.
//

import UIKit
import PhotosUI
import Combine

class ProfileDataFormViewController: UIViewController {
    // Importo el modelo de esta vista para que puedan pasarse a este los datos que vaya poniendo
    private let viewModel = ProfileDataFormViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let displayNameTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.keyboardType = .default
        textfield.backgroundColor = .secondarySystemFill
        textfield.leftViewMode = .always
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textfield.layer.masksToBounds = true
        textfield.layer.cornerRadius = 8
        textfield.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textfield
    }()
    
    private let usernameTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.keyboardType = .default
        textfield.backgroundColor = .secondarySystemFill
        textfield.leftViewMode = .always
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textfield.layer.masksToBounds = true
        textfield.layer.cornerRadius = 8
        textfield.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textfield
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fill in your data"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let avatarPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = .gray
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    // El campo del bio es una textView por lo tanto no tiene el método del addTarget, por lo tanto habrá que implementar ese método en los métodos del delegate
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .secondarySystemFill
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "Tell the world about yourself"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(hintLabel)
        scrollView.addSubview(avatarPlaceholderImageView)
        scrollView.addSubview(displayNameTextField)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(bioTextView)
        scrollView.addSubview(submitButton)
        isModalInPresentation = true
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        bioTextView.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))
        configureConstraints()
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        avatarPlaceholderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToUpload)))
        bindViews()
    }
    
    @objc private func didTapSubmit() {
        viewModel.uploadAvatar()
    }
    // Esta función hace que cuando dé al botón del submit, el texto se refleje en su respectivo campo de la vista del modelo
    @objc private func didUpdateDisplayName() {
        viewModel.displayName = displayNameTextField.text
        // LLamamos también a la función de validación que hicimos en la vista del modelo para que se ejecute con cada pulsación de tecla que hagamos en este campo
        viewModel.validateUserProfileForm()
    }
    
    @objc private func didUpdateUsername() {
        viewModel.username = usernameTextField.text
    }
    // Esta función es para enlazar los datos que vayamos poniendo en esta vista a la viewModel
    private func bindViews() {
        displayNameTextField.addTarget(self, action: #selector(didUpdateDisplayName), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(didUpdateUsername), for: .editingChanged)
        viewModel.$isFormValid.sink { [weak self] buttonState in
            self?.submitButton.isEnabled = buttonState
        }
        .store(in: &subscriptions)
        
        viewModel.$isOnboardingFinished.sink { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)
    }
    
    @objc private func didTapToUpload() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapToDismiss() {
        view.endEditing(true)
    }
    
    private func configureConstraints() {
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let hintLabelConstraints = [
            hintLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30)
        ]
        
        let avatarPlaceholderImageViewConstraints = [
            avatarPlaceholderImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            avatarPlaceholderImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 30)
        ]
        
        let displayNameTextFieldConstraints = [
            displayNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayNameTextField.topAnchor.constraint(equalTo: avatarPlaceholderImageView.bottomAnchor, constant: 40),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let usernameTextFieldConstraints = [
            usernameTextField.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let bioTextViewConstraints = [
            bioTextView.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            bioTextView.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            bioTextView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            bioTextView.heightAnchor.constraint(equalToConstant: 150)
        ]
        
        let submitButtonConstraints = [
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            // Este constraint hace que al aparecer los botones del teclado, el botón del submit suba y no se quede tapado por los botones del teclado
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(hintLabelConstraints)
        NSLayoutConstraint.activate(avatarPlaceholderImageViewConstraints)
        NSLayoutConstraint.activate(displayNameTextFieldConstraints)
        NSLayoutConstraint.activate(usernameTextFieldConstraints)
        NSLayoutConstraint.activate(bioTextViewConstraints)
        NSLayoutConstraint.activate(submitButtonConstraints)
    }
    
}

extension ProfileDataFormViewController: UITextViewDelegate, UITextFieldDelegate {
    // Esta función hace que al pulsar en el campo de la bio la frase inicial se borre y que al escribir el texto cambie a color negro
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 100), animated: true)
        if textView.textColor == .gray {
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    // Esta función hace que cuando no escribamos nada en el campo de la bio la frase inicial aparezca de nuevo
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        if textView.text.isEmpty {
            textView.text = "Tell the world about yourself"
            textView.textColor = .gray
        }
    }
    // Este es el método para reflejar (vincular) los cambios que haremos en el campo de la bio
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bio = textView.text
        viewModel.validateUserProfileForm()
    }
    // Esta función hace que al escribir en el input de display name, la vista se desplaza hácia arriba
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 100), animated: true)
    }
    // Esta función hace que al pulsar fuera del input la vista vuelva a su posición inicial
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension ProfileDataFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // Esto es para vincular los campos de las imágen con la viewModel
                        self?.avatarPlaceholderImageView.image = image
                        self?.viewModel.imageData = image
                        self?.viewModel.validateUserProfileForm()
                    }
                }
            }
        }
    }
}
