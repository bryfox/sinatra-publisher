# Sinatra Publisher

## Publish an erb-based sinatra app out to static HTML files. 

Perhaps you need to get a simple site up on GoDaddy, but can't kick the Sinatra habit.

This extension adds a `/static` route to an app, which returns a ZIP file of the site or, alternately, saves the file to a specified destination.

Supports routes with a single parameter by supplying a list of values for each route at startup.

See `example/` and `classy-example/` for usage.
