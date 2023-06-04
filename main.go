package main

import (
	"embed"
	"log"
	"net/http"
)

//go:embed templates/*
var folder embed.FS //embeds files to a virtual filesystem inside the go binary

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			fldr, err := folder.ReadFile("templates/404.html")
			if err != nil {
				log.Fatal(err)
			}

			// Write the 404 status page
			w.WriteHeader(http.StatusNotFound)
			w.Write(fldr)
			return
		}

		fldr, err := folder.ReadFile("templates/index.html")

		// Handle the error for the index.html file
		if err != nil {
			log.Fatal(err)
		}

		// Write the contents of the index.html file to the response
		w.Write(fldr)
	})

	fs := http.FileServer(http.FS(folder))
	http.Handle("/templates/", fs)

	err := http.ListenAndServe(":3389", nil)
	if err != nil {
		log.Fatal(err)
	}
}
