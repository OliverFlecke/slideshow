import Foundation

public struct Math {
    static func modulus(_ k: Int, _ n: Int) -> Int {
        let r = k % n
        return r < 0 ? r + n : r
    }
}
