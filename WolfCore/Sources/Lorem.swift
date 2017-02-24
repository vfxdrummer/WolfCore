//
//  Lorem.swift
//  WolfCore
//
//  Created by Wolf McNally on 2/21/17.
//  Copyright © 2017 Arciem. All rights reserved.
//

import Foundation

//
// Based on:
//

//
//        __                             _____         _ ______
//       / /   ____  ________  ____ ___ / ___/      __(_) __/ /___  ______ ___
//      / /   / __ \/ ___/ _ \/ __ `__ \\__ \ | /| / / / /_/ __/ / / / __ `__ \
//     / /___/ /_/ / /  /  __/ / / / / /__/ / |/ |/ / / __/ /_/ /_/ / / / / / /
//    /_____/\____/_/   \___/_/ /_/ /_/____/|__/|__/_/_/  \__/\__,_/_/ /_/ /_/
//
//                              LoremSwiftum.swift
//                 http://github.com/lukaskubanek/LoremSwiftum
//            2014-2015 (c) Lukas Kubanek (http://lukaskubanek.com)
//

public class Lorem {
    public typealias Decorator = (String) -> String

    // ======================================================= //
    // MARK: - Text
    // ======================================================= //

    public static var word: String {
        return Random.choice(among: allWords)
    }

    public static func words(_ count: Int) -> String {
        return compose({ word }, count: count, middleSeparator: .space)
    }

    public static var sentence: String {
        let numberOfWordsInSentence = Random.number(4...16)
        let capitalizeFirstLetterDecorator: Decorator = { $0.capitalizedFirstCharacter }
        return compose({ word }, count: numberOfWordsInSentence, middleSeparator: .space, endSeparator: .dot, decorator: capitalizeFirstLetterDecorator)
    }

    public static func sentences(_ count: Int) -> String {
        return compose({ sentence }, count: count, middleSeparator: .space)
    }

    public static var paragraph: String {
        let numberOfSentencesInParagraph = Random.number(3...9)
        return sentences(numberOfSentencesInParagraph)
    }

    public static func paragraphs(_ count: Int) -> String {
        return compose({ paragraph }, count: count, middleSeparator: .newLine)
    }

    public static var title: String {
        let numberOfWordsInTitle = Random.number(2...7)
        let capitalizeStringDecorator: Decorator = { $0.capitalized }
        return compose({ word }, count: numberOfWordsInTitle, middleSeparator: .space, decorator: capitalizeStringDecorator)
    }

    public static var shortTitle: String {
        let numberOfWordsInTitle = Random.number(1...3)
        let capitalizeStringDecorator: Decorator = { $0.capitalized }
        return compose({ word }, count: numberOfWordsInTitle, middleSeparator: .space, decorator: capitalizeStringDecorator)
    }

    // ======================================================= //
    // MARK: - Misc
    // ======================================================= //

    public static var femaleFirstName: String {
        return Random.choice(among: femaleFirstNames)
    }

    public static var maleFirstName: String {
        return Random.choice(among: maleFirstNames)
    }

    public static var firstName: String {
        return Random.choice(among: firstNames)
    }

    public static var lastName: String {
        return Random.choice(among: lastNames)
    }

    public static var name: String {
        return "\(firstName) \(lastName)"
    }

    public static var email: String {
        let delimiter = Random.choice(among: emailDelimiters)
        let domain = Random.choice(among: emailDomains)
        return "\(firstName)\(delimiter)\(lastName)@\(domain)".lowercased()
    }

    public static var url: URL {
        return URL(string: "http://\(Random.choice(among: domains))/")!
    }

    public static var tweet: String {
        return Random.choice(among: tweets)
    }

    public static var date: Date {
        let currentDate = Date()
        let currentCalendar = Calendar.current
        var referenceDateComponents = DateComponents()
        referenceDateComponents.year = -4
        let referenceDate: Date = currentCalendar.date(byAdding: referenceDateComponents, to: currentDate)!
        let timeIntervalSinceReferenceDate: Int = Int(referenceDate.timeIntervalSinceReferenceDate)
        let randomTimeInterval = TimeInterval(Random.number(0...timeIntervalSinceReferenceDate))
        return referenceDate.addingTimeInterval(randomTimeInterval)
    }

    public static var imageURL: URL {
        return URL(string: Random.choice(among: imageURLs))!
    }

    private static func _avatarURL(type: String) -> URL {
        let n = Random.number(0...99)
        return URL(string: "https://randomuser.me/api/portraits/\(type)/\(n).jpg")!
    }

    public static var maleAvatarURL: URL {
        return _avatarURL(type: "men")
    }

    public static var femaleAvatarURL: URL {
        return _avatarURL(type: "women")
    }

    public static var avatarURL: URL {
        return Random.boolean() ? maleAvatarURL : femaleAvatarURL
    }

    // ======================================================= //
    // MARK: - Private
    // ======================================================= //

    private enum Separator: String {
        case none = ""
        case space = " "
        case dot = "."
        case newLine = "\n"
    }

    private static func compose(_ provider: () -> String, count: Int, middleSeparator: Separator, endSeparator: Separator = .none, decorator: Decorator? = nil) -> String {
        var composedString = ""

        for index in 0..<count {
            composedString += provider()

            if (index < count - 1) {
                composedString += middleSeparator.rawValue
            } else {
                composedString += endSeparator.rawValue
            }
        }

        if let decorator = decorator {
            return decorator(composedString)
        } else {
            return composedString
        }
    }

    // ======================================================= //
    // MARK: - Data
    // ======================================================= //

    private static let allWords = "alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt neque dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad minima veniam quis nostrum exercitationem ullam corporis nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum fuga et harum quidem rerum facilis est et expedita distinctio nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est qui minus id quod maxime placeat facere possimus omnis voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et aut consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores doloribus asperiores repellat".components(separatedBy: " ")

    private static let maleFirstNames = "Abel Alberto Alfredo Allen Alonzo Alvin Andre Andres Angelo Antonio Arturo Ashton Auryn Bart Beau Bevan Billie Billy Brayden Brendan Brenden Brendon Brock Bryce Byron Caleb Calum Casey Chris Ciaran Clint Clinton Clyde Collin Colm Colton Connor Dalton Daren Darius Daryl Davion Denis Dirk Dominick Don Dwayne Earl Eli Elias Emiliano Eric Ewan George Gordon Grady Guy Hamish Harrison Harvey Hector Hudson Ian Jamal Jared Jason Javon Jerald Joey John Johnnie Johnny Kaden Kelvin Kendrick Kenneth Kerry Kerry Kieran Leland Lorenzo Luis Manuel Mohammed Monty Moses Neil Niall Nolan Omar Orlaith Patrick Pete Phil Piper Preston Quinn Rafael Randal Raul Reese Reid Robert Roberto Rogelio Rolando Ruben Samuel Shawn Teddy Terry Toby Tomas Ty Vance Virgil Wayne Wendell Yehudi Zachariah".components(separatedBy: " ")

    private static let femaleFirstNames = "Abigail Adrianna Agnes Alexa Alexandra Alexis Allyson Alma Alondra Alyson Ana Angela Angelina Aniya Annika Antoinette Beth Bianca Bonita Bonnie Brooklynn Caitlyn Camila Cara Carla Carley Carly Carmen Cathleen Chris Ciara Cindy Constance Courtney Cynthia Danielle Deana Dora Doris Dulce Elaine Elise Eliza Emely Emma Eoin Esmeralda Fatima Francesca Freya Gayle Geraldine Giselle Gretchen Harriet Ida Inley Isabel Isabelle Jackie Jacquelyn Jadyn Jamie Janet Jean Joann Jordyn Josephine Judith Justice Kailey Kaleigh Katherine Katie Kaylin Kellie Kelly Kristi Kyla Kyleigh Kyra Laila LaTonya Leslie Lexi Liliana Lori Lorie Lucinda Lynette Madeline Maggie Maisie Makenzie Margarita Marianne Marsha Marybeth Melinda Michelle Mitzi Mya Nadia Nia Nika Noel Noelle Paola Peggy Penny Perla Ruby Rylee Sadie Sheryl Shirley Sienna Skye Skylar Skyler Sonja Staci Stephanie Summer Sydney Tammie Tonia Tracy Tricia Trisha Uriel Vanessa Xena Yvonne Zoe".components(separatedBy: " ")

    private static var firstNames: [String] = {
        var a = Lorem.maleFirstNames
        a.append(contentsOf: Lorem.femaleFirstNames)
        return a
    }()

    private static let lastNames = "Chung Chen Melton Hill Puckett Song Hamilton Bender Wagner McLaughlin McNamara Raynor Moon Woodard Desai Wallace Lawrence Griffin Dougherty Powers May Steele Teague Vick Gallagher Solomon Walsh Monroe Connolly Hawkins Middleton Goldstein Watts Johnston Weeks Wilkerson Barton Walton Hall Ross Chung Bender Woods Mangum Joseph Rosenthal Bowden Barton Underwood Jones Baker Merritt Cross Cooper Holmes Sharpe Morgan Hoyle Allen Rich Rich Grant Proctor Diaz Graham Watkins Hinton Marsh Hewitt Branch Walton O'Brien Case Watts Christensen Parks Hardin Lucas Eason Davidson Whitehead Rose Sparks Moore Pearson Rodgers Graves Scarborough Sutton Sinclair Bowman Olsen Love McLean Christian Lamb James Chandler Stout Cowan Golden Bowling Beasley Clapp Abrams Tilley Morse Boykin Sumner Cassidy Davidson Heath Blanchard McAllister McKenzie Byrne Schroeder Griffin Gross Perkins Robertson Palmer Brady Rowe Zhang Hodge Li Bowling Justice Glass Willis Hester Floyd Graves Fischer Norman Chan Hunt Byrd Lane Kaplan Heller May Jennings Hanna Locklear Holloway Jones Glover Vick O'Donnell Goldman McKenna Starr Stone McClure Watson Monroe Abbott Singer Hall Farrell Lucas Norman Atkins Monroe Robertson Sykes Reid Chandler Finch Hobbs Adkins Kinney Whitaker Alexander Conner Waters Becker Rollins Love Adkins Black Fox Hatcher Wu Lloyd Joyce Welch Matthews Chappell MacDonald Kane Butler Pickett Bowman Barton Kennedy Branch Thornton McNeill Weinstein Middleton Moss Lucas Rich Carlton Brady Schultz Nichols Harvey Stevenson Houston Dunn West O'Brien Barr Snyder Cain Heath Boswell Olsen Pittman Weiner Petersen Davis Coleman Terrell Norman Burch Weiner Parrott Henry Gray Chang McLean Eason Weeks Siegel Puckett Heath Hoyle Garrett Neal Baker Goldman Shaffer Choi Carver".components(separatedBy: " ")

    private static let emailDomains = "gmail.com yahoo.com hotmail.com email.com live.com me.com mac.com aol.com fastmail.com mail.com".components(separatedBy: " ")

    private static let emailDelimiters = ["", ".", "-", "_"]

    private static let domains = "twitter.com google.com youtube.com wordpress.org adobe.com blogspot.com godaddy.com wikipedia.org wordpress.com yahoo.com linkedin.com amazon.com flickr.com w3.org apple.com myspace.com tumblr.com digg.com microsoft.com vimeo.com pinterest.com qq.com stumbleupon.com youtu.be addthis.com miibeian.gov.cn delicious.com baidu.com feedburner.com bit.ly".components(separatedBy: " ")

    // Source: http://www.kevadamson.com/talking-of-design/article/140-alternative-characters-to-lorem-ipsum
    private static let tweets = ["Far away, in a forest next to a river beneath the mountains, there lived a small purple otter called Philip. Philip likes sausages. The End.", "He liked the quality sausages from Marks & Spencer but due to the recession he had been forced to shop in a less desirable supermarket. End.", "He awoke one day to find his pile of sausages missing. Roger the greedy boar with human eyes, had skateboarded into the forest & eaten them!"]

    private static let imageURLs = [
        "https://68.media.tumblr.com/3f5d6a2ed0c4a5f1f64c95d54073bf7f/tumblr_okametxqXC1w1ctyao1_500.png", // unlikely river
        "https://68.media.tumblr.com/15a3fe1eedcbf4a7d6a950202affac5e/tumblr_of3rh4IuJ21trkvxko1_500.jpg", // space between
        "https://68.media.tumblr.com/ee912a87e833e486e614dba128a0513a/tumblr_obuwahGNwg1sn3ne4o1_500.jpg", // luminous tree
        "https://68.media.tumblr.com/0b4921df4f50a44b2d83a4b4517f66e5/tumblr_obm6a54QN31s44okeo1_500.jpg", // visitor
        "https://68.media.tumblr.com/062874323dc4358698b8ffdcf26ccd40/tumblr_o8fkrsJmhO1v1jf78o1_500.jpg", // blue sky face
        "https://68.media.tumblr.com/62961458ffbecd94749e72943b2b22ec/tumblr_o85yvko2AM1sj1s6vo1_500.jpg", // dreamscape #3
        "https://68.media.tumblr.com/c85a271c5b58546c28810d3d435f1589/tumblr_o6yveo9ILF1udk56ko1_500.jpg", // front gate
        "https://68.media.tumblr.com/3abdc77808bf1c75b470dac0e58b114e/tumblr_o5blg2Cu881voapweo8_500.jpg", // grasso house
        "https://68.media.tumblr.com/a3283144b6f16ff511c9219bfd95a29f/tumblr_o3i0xbQKZS1rr0102o1_540.jpg", // magritte human condition
        "https://68.media.tumblr.com/477f63f6b43dbb0a70692458a4b2464d/tumblr_olrjrmDDnl1vj0qybo1_540.jpg", // queen of space

        "https://68.media.tumblr.com/a7a9ac0ec9f4d5ec163d3cbc831c8878/tumblr_ojuhdklyRQ1ttzaedo1_r1_500.jpg", // the intellect
        "https://68.media.tumblr.com/9ca1d580d01f9288f6519dbe29b2fbf2/tumblr_of450kXtVY1ttzaedo1_500.jpg", // salvia droid
        "https://68.media.tumblr.com/279af3ef9994891d2136f5737077fd1a/tumblr_ntibnkhYrw1tfdblio1_500.jpg", // mattingly couple
        "https://68.media.tumblr.com/c5d63160b2af33da912e47eeef728e56/tumblr_oc78hiG5H21ttzaedo1_r1_500.png", // familiar stranger
        "https://68.media.tumblr.com/17bf718ac8387c9fd9295a8abbacc765/tumblr_nvw3tsavY71qgxdtao1_500.jpg", // beauty in perspective
        "https://68.media.tumblr.com/83fcf28632dcd16f492f7f17493df9ce/tumblr_ntnr8gtUDK1uywqfao1_500.jpg", // bautista this queer curiosity
        "https://68.media.tumblr.com/8d3f3f938b49ea4dae3a6fb674a6c954/tumblr_nrjecjv3Pe1u1uaauo1_500.jpg", // bautista mine
        "https://68.media.tumblr.com/ac6a52b3f129da7a551515a6e5f15f7a/tumblr_nmcmic62Oi1u1uaauo1_500.jpg", // bautista no
        "https://s-media-cache-ak0.pinimg.com/736x/b3/cb/a5/b3cba5d6b7d7b7013a0e282a8dbbc607.jpg", // parkes juggler
        "https://s-media-cache-ak0.pinimg.com/736x/c7/65/0a/c7650affd2fa0d4e2cda5128a2275976.jpg", // parkes gargoyle
    ]
}