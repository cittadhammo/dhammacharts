---
title: The Illustrated Manual of Buddhist Terms & Doctrines
license: CC0
techs: 
  - D3
  - Python
  - Node.js
  - ChatGPT
images:
  - name: A1S-Manual.png
    map: true
sources:
  - name: The Manual of Buddhist Terms & Doctrines
    author: Nyanatiloka Thera
    links:
	  - name: PDF
	    url: https://www.buddhistelibrary.org/buddhism-online/e-books/palidictionary.pdf
	  - name: PDF 2
	    url: https://buddhistuniversity.net/content/reference/buddhist-dictionary_nyanatiloka
	  - name: Web
	    url: https://www.palikanon.com/english/wtb/dic_idx.html
  - name: Research Paper
    author: Yuntao Jia, Michael Garland, J. Hart
    links:
	  - name: PDF
	    url: https://www.semanticscholar.org/paper/Hierarchical-Edge-Bundles-for-General-Graphs-Jia-Garland/31f3ae917eaf2c1562274356cf7759d6a547cb69
code: 
  - name: Notebook
    url: https://observablehq.com/d/2d1af81c02434761
---

The goal of this project is to explore the graph created by mapping the links and references of the book: *Buddhist Dictionary: A Manual of Buddhist Terms and Doctrines* By Nyanatiloka Thera

The chart below explore the connections of the different entries in the dictionary. The text size is according to the number of entries the entry quotes or get quoted. The structure is revealed via the Hierarchical Edge Bundles for General Graphs Method explained below.

From there, there are multiple ways to represent and analyse the network. We will follow a graph visualization approach that extracts the community structure of a network and organizes it into a more balanced and meaningful hierarchy so that its edge bundle rendering better indicates its structure from Yuntao Jia, Michael Garland, J. Hart

Hierarchical Edge Bundles for General Graphs

in 2009, researchers have develop a technique to visualize a graph of relationships by generating a hierarchy between the nodes and then using the well known Edge Bundling technic in a radial graph. We need first to break down the main network into subgraph with the **python** code below

![[manual.jpeg]]