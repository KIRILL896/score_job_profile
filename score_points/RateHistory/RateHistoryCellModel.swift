

import Foundation
import RxSwift
import RxDataSources

struct RateHistoryCellModel: IdentifiableType, Hashable, Equatable {
  typealias Identity = String
  var identity: String { return rate.id }
  let type:String
  let rate: Rate
  let user: UserData
  var shown:Bool
  var elems:[Score.ScoreElem] = []
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.user.userId == rhs.user.userId &&
      lhs.rate.id == rhs.rate.id
  }
  
  func hash(into hasher: inout Hasher) {
      hasher.combine(rate.id)
  }
}


struct RateHistorySectionModel {
  var items: [Item]
  var title: String
  var id: String
}

extension RateHistorySectionModel: SectionModelType {
  init(original: RateHistorySectionModel, items: [RateHistoryCellModel]) {
    self.title = original.title
    self.id = original.id
    self.items = items
  }
  
  typealias Item = RateHistoryCellModel
}

extension RateHistorySectionModel: AnimatableSectionModelType {
  typealias Identity = [Item]
  
  var identity: [Item] {
    return items
  }
}
