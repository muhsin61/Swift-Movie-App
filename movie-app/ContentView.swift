//
//  ContentView.swift
//  movie-app
//
//  Created by Muhsin Köse on 12.06.2022.
//

import SwiftUI

struct Result: Codable {
    var id: Int
    var original_title: String
    var overview: String
}

struct Response: Codable {
    var results: [Result]
    var page: Int
    var total_results: Int
    var total_pages: Int
}

struct ContentView: View {
    @State private var srcText = "";
    @State private var movieData: Array<Result> = Array();
    @State private var page: Int = 1;
    
    @State private var results = [Result]()
    @State private var total_pages = 0

    
    let apiUrl = "https://api.themoviedb.org/3/search/movie?&api_key=04c35731a5ee918f014970082a0088b1";
    var params = "&query=kara&page=1"
    
    func searchMovie(){
        Task{
            await getMovies()
        }
    }
    func getMovies() async{
        
        let url = URL(string: apiUrl + "&query=" + srcText + "&page=1")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data!) {
                movieData = decodedResponse.results
                total_pages = decodedResponse.total_pages
                page = decodedResponse.total_pages
            }
        }.resume() // important
        
    }
    var body: some View {
        VStack {
            Text("Find Movie")
                .padding()
                .font(.title)
                .foregroundColor(.green)
            HStack{
                TextField("Search movie", text: $srcText)
                Button("Search") {
                    searchMovie()
                }
            }
            .padding()
            Text(srcText)
            if(!movieData.isEmpty){
                List((1...movieData.count), id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(movieData[index-1].original_title)
                        .font(.headline)
                    }
                }
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
