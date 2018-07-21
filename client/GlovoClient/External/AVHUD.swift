import Foundation

class AVHUD: NSObject {
    static func show() {
        self.show(status: "loading")
    }

    @objc static func show(status: String) {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.darkGray.withAlphaComponent(0.6))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.show(withStatus: status)
    }

    static func showError(status: String) {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.darkGray.withAlphaComponent(0.6))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.showError(withStatus: status)
    }

    static func showSuccess(status: String) {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.showSuccess(withStatus: status)
    }

    static func showSuccess(status: String, image: UIImage) {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.show(image, status: status)
    }

    @objc static func dismiss() {
        SVProgressHUD.dismiss()
    }
}
