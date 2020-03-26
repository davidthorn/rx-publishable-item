//
//  BehaviorRelayTests.swift
//  PublishableItemTests
//
//  Created by Thorn, David on 26.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

class BehaviorRelayTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testBehaviorRelay() {

        let relay = BehaviorRelay<String>(value: "One")

        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        relay.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            relay.accept("Two")
        }

        scheduler.start()

        let recordedEvents: [Recorded<Event<String>>] = [
            .next(0, "One"),
            .next(10, "Two")
        ]

        XCTAssertEqual(observer.events, recordedEvents)
        scheduler.stop()
        XCTAssertEqual(relay.value, "Two")

    }

}
