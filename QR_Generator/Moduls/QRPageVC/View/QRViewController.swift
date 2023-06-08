//
//  QRViewController.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 5.06.2023.
//


import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import CoreImage
import Photos

class QRViewController: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    
    let disposeBag = DisposeBag()
    var qrImage: UIImage?

    var playerID: String?
    var xCoordinate: String?
    var yCoordinate: String?
    var employeeKey: String?
    var date: String?
    var time: String?
    let locationManager = CLLocationManager()
    var timer: Timer?
    let qrRefreshInterval: TimeInterval = 10

    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Ekran görüntüsü alındığında veya alınmaya başlandığında tetiklenecek metodu tanımlayın
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopQRRefreshTimer()
    }
    
    
    @objc func handleScreenshot() {
        self.stopQRRefreshTimer()
        self.qrImageView.image = nil
        self.qrImageView.isHidden = true
        self.errorView.isHidden = false
        self.errorLbl.text = "Uyarı \n QR Code geçersiz olmuştur. \nEkran görüntüsü alındığı zaman QR Code geçersiz olur ve giriş bilgileriniz silinir."
    }
    
    ///Func
    private func btnAction() {
        closeBtn.rx.tap.bind {
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func startQRRefreshTimer() {
        stopQRRefreshTimer()
        timer = Timer.scheduledTimer(timeInterval: qrRefreshInterval, target: self, selector: #selector(refreshQR), userInfo: nil, repeats: true)
    }

    func stopQRRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func refreshQR() {
        locationManager.startUpdatingLocation()
    }
    
   
}

extension QRViewController {
//    func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
//
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 5, y: 5)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//        return nil
//    }

//    func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: .utf8)// Veri kodlama biçimini .utf8 olarak değiştirdik
//
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 5, y: 5) // Ölçeklendirme faktörünü 5 olarak ayarladık
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                let context = CIContext()
//                if let cgImage = context.createCGImage(output, from: output.extent) {
//                    return UIImage(cgImage: cgImage)
//                }
//            }
//        }
//        return nil
//    }
    
    ///base64 olarak qr oluşturma isteniyorsa
//    func generateQRCode(from string: String) -> UIImage? {
//
//        if let data = string.data(using: .utf8) {
//            let base64String = data.base64EncodedData()
//            if let filter = CIFilter(name: "CIQRCodeGenerator") {
//                filter.setValue(base64String, forKey: "inputMessage")
//                let transform = CGAffineTransform(scaleX: 5, y: 5)
//
//                if let output = filter.outputImage?.transformed(by: transform) {
//                    let context = CIContext()
//                    if let cgImage = context.createCGImage(output, from: output.extent) {
//                        return UIImage(cgImage: cgImage)
//                    }
//                }
//            }
//        }
//        return nil
//    }
    ///ortasında logo olması isteniyorsa
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let logo = UIImage(named: "migros")

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel") // Error düzeltme seviyesini ayarlayın

            if let output = filter.outputImage {
                // QR kodunu ölçeklendirin
                let transform = CGAffineTransform(scaleX: 5, y: 5)
                let scaledOutput = output.transformed(by: transform)

                // Çıktıyı CGImage olarak oluşturun
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledOutput, from: scaledOutput.extent) {
                    var qrImage = UIImage(cgImage: cgImage)

                    // Logo ekleme
                    if let logo = logo {
                        let logoSize = CGSize(width: qrImage.size.width * 0.1, height: qrImage.size.height * 0.1)
                        let xPos = (qrImage.size.width - logoSize.width) / 2
                        let yPos = (qrImage.size.height - logoSize.height) / 2
                        let logoRect = CGRect(x: xPos, y: yPos, width: logoSize.width, height: logoSize.height)

                        UIGraphicsBeginImageContextWithOptions(qrImage.size, false, 0)
                        qrImage.draw(in: CGRect(origin: .zero, size: qrImage.size))
                        logo.draw(in: logoRect)
                        qrImage = UIGraphicsGetImageFromCurrentImageContext() ?? qrImage
                        UIGraphicsEndImageContext()
                    }

                    return qrImage
                }
            }
        }

        return nil
    }
    
    func createQR() {
        locationManager.stopUpdatingLocation()
        ///DeviceId
        if let deviceUUID = UIDevice.current.identifierForVendor?.uuidString {
            self.playerID = deviceUUID
        } else {
            self.playerID = "Cihaz UUID alınamadı."
        }
        
        ///EmployeeKey
        self.employeeKey = "9614"
        
        if let playerID = playerID, let xCoordinate = xCoordinate, let yCoordinate = yCoordinate, let employeeKey = employeeKey, let date = date, let time = time {
            let qrData = """
                PlayerID: \(playerID)
                X: \(xCoordinate)
                Y: \(yCoordinate)
                EmployeeKey: \(employeeKey)
                Tarih: \(date)
                Saat: \(time)
                """
            print("qrData:", qrData)
            if let qrImage = generateQRCode(from: qrData) {
                self.errorView.isHidden = true
                self.qrImageView.isHidden = false
                self.qrImageView.image = qrImage
            } else {
                self.errorView.isHidden = false
                self.errorLbl.text = "QR kodunuz oluşurken bir hata ile karşılaşıldı tekrar deneyiniz."
                self.qrImageView.isHidden = true
            }
        }else {
            self.errorView.isHidden = false
            self.qrImageView.isHidden = true
        }
    }
}

extension QRViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted, .notDetermined:
            self.errorView.isHidden = false
            self.errorLbl.text = "Bilgilendirme \nQR oluşturulamadı. Konum izinleirnizi kontrol ediniz."
            self.qrImageView.isHidden = true
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }

            if (placemarks?.first) != nil {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: currentDate)

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                let timeString = timeFormatter.string(from: currentDate)

                self.xCoordinate = String(location.coordinate.latitude)
                self.yCoordinate = String(location.coordinate.longitude)
                self.date = dateString
                self.time = timeString
                self.createQR()
                self.startQRRefreshTimer()
            } else {
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
}

extension QRViewController {
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style, action btnTitle: String = "Tamam") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: btnTitle, style: .cancel))
        self.present(alert, animated: true)
    }
}
