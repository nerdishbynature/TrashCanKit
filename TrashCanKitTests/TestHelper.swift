import Foundation

class TestHelper {
    static func loadJSON(name: String) -> [String: AnyObject] {
        let bundle = NSBundle(forClass: self)
        let path = bundle.pathForResource(name, ofType: "json")
        if let path = path, data = NSData(contentsOfFile: path) {
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.MutableContainers)
            if let json = json as! [String: AnyObject]? {
                return json
            }
        }

        return Dictionary()
    }
}
