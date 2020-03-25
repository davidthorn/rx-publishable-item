//
//  PublishableItemTests.swift
//  PublishableItemTests
//
//  Created by Thorn, David on 25.03.20.
//  Copyright © 2020 Thorn, David. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import PublishableItem

struct Person: Codable {
    let name: String
}

struct MockPerson: Codable {
    let name: PublishableItem<String?>
}

class PublishableItemTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testEncodeDecodeMockPerson() {
        let item = MockPerson(name: .init(item: "David"))
        XCTAssertEqual(item.name.value, "David")

        do {
            let encoded = try JSONEncoder().encode(item)
            let person = try JSONDecoder().decode(MockPerson.self, from: encoded)
            XCTAssertEqual(person.name.value, "David")
        } catch {
            XCTFail("This test should not fail")
        }
    }

    func testScheduler() {

        let mockPerson = MockPerson(name: .init(item: nil))
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String?.self)

        mockPerson.name.subject.subscribe(observer).disposed(by: disposeBag)
        mockPerson.name.subject.on(.next("David"))
        XCTAssertEqual(mockPerson.name.value, "David")
        mockPerson.name.subject.on(.next("James"))
        XCTAssertEqual(mockPerson.name.value, "James")
        mockPerson.name.subject.on(.next("Thorn"))
        XCTAssertEqual(mockPerson.name.value, "Thorn")
        scheduler.start()

        let recorded: [Recorded<Event<String?>>] = [
            .next(0, "David"),
            .next(0, "James"),
            .next(0, "Thorn")
        ]
        XCTAssertEqual(observer.events, recorded)
        scheduler.stop()
        XCTAssertEqual(mockPerson.name.value, "Thorn")
    }

    func testDecodedScheduler() {

        var mockPerson: MockPerson!

        do {
            let item = MockPerson(name: .init(item: "David"))
            let encoded = try JSONEncoder().encode(item)
            mockPerson = try JSONDecoder().decode(MockPerson.self, from: encoded)
        } catch {
            XCTFail("This test should not fail")
        }

        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String?.self)

        mockPerson.name.subject.subscribe(observer).disposed(by: disposeBag)
        mockPerson.name.subject.on(.next("David"))
        XCTAssertEqual(mockPerson.name.value, "David")
        mockPerson.name.subject.on(.next("James"))
        XCTAssertEqual(mockPerson.name.value, "James")
        mockPerson.name.subject.on(.next("Thorn"))
        XCTAssertEqual(mockPerson.name.value, "Thorn")
        scheduler.start()

        let recorded: [Recorded<Event<String?>>] = [
            .next(0, "David"),
            .next(0, "James"),
            .next(0, "Thorn")
        ]
        XCTAssertEqual(observer.events, recorded)
        scheduler.stop()
        XCTAssertEqual(mockPerson.name.value, "Thorn")
    }

}
