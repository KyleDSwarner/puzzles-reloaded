//
//  GameHelpView.swift
//  Puzzles Reloaded
//
//  Created by Kyle Swarner on 5/24/24.
//  Copyright © 2024 Kyle Swarner. All rights reserved.
//

import SwiftUI
import Down // Import Down framework

struct GameHelpView: View {
    
    let gameHelpData: HelpModel?
    var markdownText: AttributedString = ""
    
    let markdownFileName = "abcd" // Name of your Markdown file

    init(gameHelpData: HelpModel?) {
        self.gameHelpData = gameHelpData
        
        /*
        if let filePath = Bundle.main.path(forResource: markdownFileName, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filePath)
                print("Contents!")

                print(markdownText)
                //AttributedString(mark)
                let astr = try! AttributedString(markdown: contents, options: AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true, ))
                
                markdownText = astr
            } catch {
                print("Error reading Markdown file:", error)
            }
        } else {
            print("Markdown file not found.")
        }
         */
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            ScrollView {
                Text("ABCD").font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(gameHelpData?.gameDescription ?? "No Help Text Found")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 20)
                
                Text("Controls").font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(gameHelpData?.gameControls ?? "No Controls Text Found")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            
            .padding(15)
        }
        .frame(maxWidth: .infinity)
        
        /*
        VStack {
            Text(markdownText)
        }
         */
        
        /*
        if let markdown = readMarkdownFile(named: markdownFileName),
           let attributedString = parseMarkdownContent(markdown) {
            return Text("\(attributedString)")
                .padding()
        } else {
            return Text("Failed to load Markdown content.")
                .padding()
        }
         */
    }
    
    func readMarkdownFile(named fileName: String) -> String? {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filePath)
                return contents
            } catch {
                print("Error reading Markdown file:", error)
                return nil
            }
        } else {
            print("Markdown file not found.")
            return nil
        }
    }
    
    

    func parseMarkdownContent(_ markdown: String) -> NSAttributedString? {
        let down = Down(markdownString: markdown)
        do {
            let attributedString = try down.toAttributedString()
            print(attributedString)
            return attributedString
        } catch {
            print("Error parsing Markdown content:", error)
            return nil
        }
    }
}

#Preview {
    let helpData: HelpModel = HelpModel(gameDescription: """
      Whazzup This is a cool game what do you think about it? I like peanuts apparently I mean they're pretty good but why did I say that?
      do you like peanuts? I do
      """, gameControls: """
    - Do something here
    1. I like you.
    """)
    return GameHelpView(gameHelpData: helpData)
}
