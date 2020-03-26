//
//  ReplaySubjectTests.swift
//  PublishableItemTests
//
//  Created by Thorn, David on 26.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import XCTest
import RxTest
import RxSwift

class ReplaySubjectTests: XCTestCase {

    let disposeBag = DisposeBag()

    enum MockError: Error {
        case error
    }

    /// Creating test to be sure that I understand how the Replay Subject works so that it can be converted to Replayable Items.
    func testReplaySubject() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        let observer1 = scheduler.createObserver(String.self)

        let replaySubject = ReplaySubject<String>.create(bufferSize: 3)
        replaySubject.subscribe(observer).disposed(by: disposeBag)

        replaySubject.on(.next("One"))

        scheduler.scheduleAt(100) {
            replaySubject.on(.next("Two"))
        }

        scheduler.scheduleAt(200) {
            replaySubject.on(.error(MockError.error))
        }

        scheduler.scheduleAt(300) {
            replaySubject.on(.next("Three"))
        }

        replaySubject.subscribe(observer1).disposed(by: disposeBag)

        scheduler.start()

        let recorded: [Recorded<Event<String>>] = [
            .next(0, "One"),
            .next(100, "Two"),
            .error(200, MockError.error)
        ]

        XCTAssertEqual(observer1.events, recorded)
        XCTAssertEqual(observer.events, recorded)
        scheduler.stop()
    }

}

