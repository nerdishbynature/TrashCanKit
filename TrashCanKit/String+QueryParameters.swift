import Foundation

extension String {
    internal var tkk_queryParameters: [String: String] {
        let parametersArray = componentsSeparatedByString("&")
        var parameters = [String: String]()
        parametersArray.forEach() { parameter in
            let keyValueArray = parameter.componentsSeparatedByString("=")
            let (key, value) = (keyValueArray.first, keyValueArray.last)
            if let key = key?.stringByRemovingPercentEncoding, value = value?.stringByRemovingPercentEncoding {
                parameters[key] = value
            }
        }
        return parameters
    }
}
