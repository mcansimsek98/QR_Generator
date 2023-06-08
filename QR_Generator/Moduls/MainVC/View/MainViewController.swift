//
//  MainVC.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 5.06.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    @IBOutlet weak var createQrCodeBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    let dispoeseBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
    }
    
    private func btnAction() {
        loginBtn.rx.tap.bind {
            self.showAlert(title: "Bilgilendirme", message: "Üzgünüz. Geliştirmemiz devam etmektedir.", preferredStyle: .alert)
        }.disposed(by: dispoeseBag)
        
        createQrCodeBtn.rx.tap.bind {
            let destinationVC = QRViewController()
            destinationVC.modalPresentationStyle = .fullScreen
            self.present(destinationVC, animated: true, completion: nil)
        }.disposed(by: dispoeseBag)
    }
    
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style, action btnTitle: String = "Tamam") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: btnTitle, style: .cancel))
        self.present(alert, animated: true)
    }

}
