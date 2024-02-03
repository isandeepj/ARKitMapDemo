//
//  ViewController.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
        // Do any additional setup after loading the view.
    }

    @IBAction func didTappedStart(_ sender: UIButton) {
        cameraAuthorization { [weak self] cameraStatus in
            guard cameraStatus == .authorized else {
                self?.showCameraDeniedAlert()
                return
            }
            self?.openARMap()
        }
    }
    func openARMap() {
        guard let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ARMapPOIViewController") else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func showCameraDeniedAlert() {
        let alertController = UIAlertController(title: "Camera access is disabled", message: "You have denied camera access on your device. To enable camera access visit your application settings.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }

    private func cameraAuthorization(_ completionHandler: @escaping (AVAuthorizationStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                completionHandler(granted ? .authorized : .denied)
            })
        default:
            completionHandler(status)
        }
    }
}

