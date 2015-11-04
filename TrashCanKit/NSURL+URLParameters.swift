import Foundation

internal extension NSURL {
    func URLParameters() -> [String: String] {
        let stringParams = absoluteString.componentsSeparatedByString("?").last
        let params = stringParams?.componentsSeparatedByString("&")
        var returnParams: [String: String] = [:]
        if let params = params {
            for param in params {
                let keyValue = param.componentsSeparatedByString("=")
                if let key = keyValue.first, value = keyValue.last {
                    returnParams[key] = value
                }
            }
        }
        return returnParams
    }
}
