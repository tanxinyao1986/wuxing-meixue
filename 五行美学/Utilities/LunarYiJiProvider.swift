import Foundation
#if canImport(LunarSwift)
import LunarSwift
#endif

struct YiJi {
    let yi: [String]
    let ji: [String]
}

final class LunarYiJiProvider {
    static let shared = LunarYiJiProvider()

    private init() {}

    func yiJi(for date: Date) -> YiJi {
        #if canImport(LunarSwift)
        let solar = Solar.fromDate(date: date)
        let lunar = solar.lunar
        let yi = lunar.dayYi
        let ji = lunar.dayJi
        return YiJi(yi: yi, ji: ji)
        #else
        return YiJi(yi: [], ji: [])
        #endif
    }
}
