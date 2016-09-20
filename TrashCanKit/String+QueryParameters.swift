import Foundation

extension String {
    internal var tkk_queryParameters: [String: String] {
        let parametersArray = components(separatedBy: "&")
        var parameters = [String: String]()
        parametersArray.forEach() { parameter in
            let keyValueArray = parameter.components(separatedBy: "=")
            let (key, value) = (keyValueArray.first, keyValueArray.last)
            if let key = key?.removingPercentEncoding, let value = value?.removingPercentEncoding {
                parameters[key] = value
            }
        }
        return parameters
    }
}
