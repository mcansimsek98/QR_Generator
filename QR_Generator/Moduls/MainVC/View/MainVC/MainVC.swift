//
//  MainVC.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 7.06.2023.
//

import UIKit
import RxSwift
import RxCocoa

class MainVC: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var selectIsDefaultBtn: UIButton!
    @IBOutlet weak var selectDataType: UIButton!
    @IBOutlet weak var selectLogo: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var selectedLogoView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    let disposeBag = DisposeBag()
    
    var isDefault: Bool?
    var dataType: String = ""
    var logoImage: UIImage?
    var inputText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        btnActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTextView()
    }
    
    func configureTextView() {
        textView.delegate = self
        textView.text = "Enter text..."
        textView.textColor = UIColor.darkGray
    }
    
    func configure() {
        self.view.setVerticalGradientBackground(startColor: .white, endColor: UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 226.0/255.0, alpha: 1.0))
    }
    
    func refreshView() {
        textView.delegate = self
        textView.text = "Enter text..."
        textView.textColor = UIColor.darkGray
        selectIsDefaultBtn.setAttributedTitle(NSAttributedString(string: " * --"), for: .normal)
        selectDataType.setAttributedTitle(NSAttributedString(string: " * Select The Type of Data"), for: .normal)
        selectedLogoView.isHidden = true
        logoImageView.image = nil
        logoImage = nil

    }
    func btnActions() {
        ///selectIsDefaultBtn
        selectIsDefaultBtn.rx.tap.bind {
            let list = ["Yes","No"]
            self.showOptionsAlert(title: "Do you want the default QR code?", options: list) { item in
                self.selectIsDefaultBtn.setAttributedTitle(NSAttributedString(string: "   \(item)"), for: .normal)
                self.selectIsDefaultBtn.setTitleColor(.darkGray, for: .normal)
                self.selectIsDefaultBtn.layer.borderWidth = 0
                self.isDefault = item == "Yes" ? true : false
            }
        }.disposed(by: disposeBag)
        
        ///selectDataType
        selectDataType.rx.tap.bind {
            let list =  ["ascii",
                         "nextstep",
                         "japaneseEUC",
                         "utf8",
                         "isoLatin1",
                         "nonLossyASCII",
                         "shiftJIS",
                         "isoLatin2",
                         "unicode",
                         "windowsCP1251",
                         "windowsCP1252",
                         "windowsCP1253",
                         "windowsCP1254",
                         "windowsCP1250",
                         "iso2022JP",
                         "macOSRoman",
                         "utf16",
                         "utf16BigEndian",
                         "utf16LittleEndian",
                         "utf32",
                         "utf32BigEndian",
                         "utf32LittleEndian"]
            self.showOptionsAlert(title: "Select The Type of Data", options: list) { item in
                self.selectDataType.layer.borderWidth = 0
                self.selectDataType.setAttributedTitle(NSAttributedString(string: "   \(item)"), for: .normal)
                self.selectDataType.setTitleColor(.darkGray, for: .normal)
                self.dataType = item
            }
        }.disposed(by: disposeBag)
        
        ///selectLogo
        selectLogo.rx.tap.bind {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        ///textView
        textView.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.inputText = text ?? ""
            })
            .disposed(by: disposeBag)
        ///createBtn
        createBtn.rx.tap.bind {
            
            if self.inputText != "" && !self.inputText.isEmpty && self.inputText != "Enter text..." , self.dataType != "" , self.isDefault != nil {
                let destinationVC = QRDetailVC()
                destinationVC.dataType = self.dataType
                destinationVC.inputText = self.inputText
                destinationVC.isDefault = self.isDefault
                destinationVC.logoImage = self.logoImage
                destinationVC.modalPresentationStyle = .fullScreen
                self.present(destinationVC, animated: true, completion: nil)
            }else {
                self.showAlert(title: "", message: "Mandatory fields cannot be left blank", preferredStyle: .alert)
                self.textView.layer.borderWidth = self.inputText != "" && !self.inputText.isEmpty && self.inputText != "Enter text..." ? 0 : 1
                self.textView.layer.borderColor = UIColor.red.cgColor
                
                self.selectDataType.layer.borderWidth = self.dataType != "" ? 0 : 1
                self.selectDataType.layer.borderColor = UIColor.red.cgColor
                
                self.selectIsDefaultBtn.layer.borderWidth = self.isDefault != nil ? 0 : 1
                self.selectIsDefaultBtn.layer.borderColor = UIColor.red.cgColor

            }
        }.disposed(by: disposeBag)
    }
}


extension MainVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkGray {
            textView.text = nil
            textView.textColor = UIColor.black.withAlphaComponent(0.7)
            textView.layer.borderWidth = 0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            configureTextView()
        }
    }
}

extension MainVC {
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style, action btnTitle: String = "Cancel") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: btnTitle, style: .cancel))
        self.present(alert, animated: true)
    }
    
    func showOptionsAlert(title: String, options: [String], completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { (_) in
                completion(option)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedLogoView.isHidden = false
            logoImageView.image = selectedImage
            logoImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        selectedLogoView.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}
