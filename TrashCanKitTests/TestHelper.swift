import Foundation

class TestHelper {
    static func loadJSON(_ name: String) -> [String: AnyObject] {
        let bundle = Bundle(for: self)
        let path = bundle.path(forResource: name, ofType: "json")
        if let path = path, let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let json: AnyObject? = try! JSONSerialization.jsonObject(with: data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            if let json = json as! [String: AnyObject]? {
                return json
            }
        }

        return Dictionary()
    }

    static func loadJSONString(_ name: String) -> String {
        let bundle = Bundle(for: self)
        let path = bundle.path(forResource: name, ofType: "json")
        if let path = path, let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let jsonString = String(data: data, encoding: String.Encoding.utf8)
            if let json = jsonString {
                return json
            }
        }

        return ""
    }
}
