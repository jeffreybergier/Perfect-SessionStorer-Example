//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

import PerfectSessionStorer

// Register the SessionStorer Filter with the servers request filters
// This is required so that the SessionStorer can set the appropriate Cookie Tokens on every request/response
server.setRequestFilters([(SessionInMemoryStringStorer.shared.filter, .low)])

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/") { request, response in
    // Get the username for this session
    // browse to 0.0.0.0:8181/ to see there is no username set
    let username = SessionInMemoryStringStorer.shared[request, "username"] ?? "USER_NOT_LOGGED_IN"
    
    // put the username in the response
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Username = \(username)</body></html>")
    response.completed()
}
routes.add(method: .get, uri: "/login") { request, response in
    // Get the username for this session
    // Now browse to 0.0.0.0:8181/login?username=billy
    // to set the username to billy
    // then browse to / to see it
    SessionInMemoryStringStorer.shared[request, "username"] = request.param(name: "username")
    
    // put the username in the response
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Username Saved: \(request.param(name: "username") ?? "USERNAME_NOT_SAVED")</body></html>")
    response.completed()
}

server.addRoutes(routes)
server.serverPort = 8181
server.documentRoot = "./webroot"
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
