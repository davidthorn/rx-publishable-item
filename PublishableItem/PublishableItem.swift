//
//  PublishableItem.swift
//  PublishableItem
//
//  Created by Thorn, David on 24.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import RxSwift
import RxCocoa

final public class PublishableItem<T: Codable>: Codable {

    private let disposeBag = DisposeBag()
    private let _item: T
    private let itemReplay: BehaviorRelay<T>
    let subject: PublishSubject<T>

    public init(item: T) {
        _item = item
        itemReplay = .init(value: item)
        self.subject = .init()
        self.subject.asDriver(onErrorJustReturn: item).drive(itemReplay).disposed(by: disposeBag)
    }

    public var value: T {
        return itemReplay.value
    }

    enum CodingKeys: CodingKey {
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _item = try values.decode(T.self, forKey: .value)
        itemReplay = .init(value: _item)
        subject = .init()
        subject.asDriver(onErrorJustReturn: _item).drive(itemReplay).disposed(by: disposeBag)
    }

    deinit {
        subject.on(.completed)
        debugPrint("deinit")
    }
}

