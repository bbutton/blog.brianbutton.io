---
title: DBaaS and SSL – connecting to CenturyLink Cloud’s Database as a Service with SSL with Ruby
author: Brian Button
type: post
date: 2015-09-17T17:02:52+00:00
draft: true
private: true
url: /index.php/2015/09/17/dbaas-and-ssl-connecting-to-centurylink-clouds-database-as-a-service-with-ssl-with-ruby/
categories:
  - Uncategorized

---
In this post, I&#8217;ll explain a simple example of how to connect to [CenturyLink Cloud][1]&#8216;s <a href="https://www.ctl.io/dbaas/" target="_blank">Database as a Service</a> (DBaaS) offering through <a href="https://www.ctl.io/appfog/" target="_blank">AppFog</a> using SSL. I&#8217;ll assume a little bit of knowledge of <a href="https://www.cloudfoundry.org/" target="_blank">CloudFoundry</a>, the platform AppFog is built on, but not much.

# Introduction

In this example, I&#8217;ll show a simple Ruby/Sinatra app that binds to an existing DBaaS MySQL instance over SSL and validates that the connection is operational. To prepare for this, I&#8217;ll first create a MySQL instance through the CloudFoundry command line for us to bind to.

## Prerequisites

Before we start, there are a couple pre-requisites you need to understand and have set up:
  
* [A CenturyLink Cloud account enabled for AppFog][2].
  
* The [CloudFoundry CLI][3] installed.

## Preparing AppFog

The firs step is to [log into AppFog using your credentials created for you through the AppFog ControlPanel UI][4]. Once you&#8217;re logged in, use the marketplace command to ensure that you have access to the DBaaS MySQL service:

<pre class="brush: plain; title: ; notranslate" title="">Brians-MacBook-Pro:~ bbutton$ cf marketplace
Getting services from marketplace in org T3OS / space Dev as admin...
OK

service       plans                description
ctl_mysql     free                 CenturyLink&#039;s BETA MySQL DBaaS.  For development use only; not subject to SLAs.
orchestrate   free                 Orchestrate DBaaS

TIP:  Use &#039;cf marketplace -s SERVICE&#039; to view descriptions of individual plans of a given service.
</pre>

Following the advice above, we can see the plans available for ctl_mysql. These plans define the quotas and costs for using a service:

<pre class="brush: plain; title: ; notranslate" title="">Brians-MacBook-Pro:~ bbutton$ cf marketplace -s ctl_mysql
Getting service plan information for service ctl_mysql as admin...
OK

service plan   description                                                                                                                                                                                                                                                                                                                 free or paid
free           UnManaged MySQL-compatible Database as a Service - 1vCPU/1GB, up to 100MB storage, 100 concurrent connections, daily backups held locally for 7 days.  SSL Encryption option.  This service is a 0.1 beta release and not subject to any SLAs. Please see CenturyLink Cloud Supplemental Terms for Beta terms of service.   free
</pre>

With knowledge of the service name, we can create an instance of that service. The service instance is a long-lived, provisioned MySQL database, created with unique credentials and SSL information that live as long as the instance exists.

<pre class="brush: plain; title: ; notranslate" title="">Brians-MacBook-Pro:~ bbutton$ cf create-service ctl_mysql free example-dbaas-instance
Creating service instance example-dbaas-instance in org T3OS / space Dev as brianbuttonxp...
OK
</pre>

We can then see our service ready for us to use:

<pre class="brush: plain; title: ; notranslate" title="">Brians-MacBook-Pro:~ bbutton$ cf services
Getting services in org T3OS / space Dev as brianbuttonxp...
OK

name                     service       plan        bound apps       last operation
my_orchestrate           orchestrate   free                         create succeeded
example-dbaas-instance   ctl_mysql     free                         create succeeded
</pre>

At this point, we have everything that we need to be able to write our program and connect to MySQL.

## Accessing the database from Ruby

I&#8217;m using a simple Sinatra app to access AppFog and my MySQL instance. This will give me an easy way to create an endpoint I can hit from my browser to cause the database connection to be created. I&#8217;ll only discuss the relevant parts of the application here, but the entire codebase is available on [github][5].

### main.rb

This is the entry point of our Sinatra app. The interesting bits of this file begin with the `ENV["VCAP_SERVICES]` and continues beyond. The _VCAP_SERVICES_ environment variable is set by CloudFoundry as your application is being staged and deployed. It will hold the information needed to consume any services to which your application will bind. For our MySQL instance, the VCAP_SERVICES variable will hold something like this:

<pre class="brush: plain; title: ; notranslate" title="">Brians-MacBook-Pro:Database bbutton$ cf env bab-dbaas-test
Getting env variables for app bab-dbaas-test in org T3OS / space Dev as brianbuttonxp...
OK

System-Provided:
{
 "VCAP_SERVICES": {
  "ctl_mysql": [
   {
    "credentials": {
     "certificate": "-----BEGIN CERTIFICATE-----\nMIIDgTCCAmmgAwIBAgIJAMubOSUqSIZOMA0GCSqGSIb3DQEBCwUAMFcxGTAXBgNV\nBAoMEENlbnR1cnlMaW5rREJhYVMxHTAbBgNVBAsMFENlcnRpZmljYXRlQXV0aG9y\naXR5MRswGQYDVQQDDBJDZW50dXJ5TGlua0RCYWFTQ0EwHhcNMTUwNjEyMDExMzIx\nWhcNMjUwNjA5MDExMzIxWjBXMRkwFwYDVQQKDBBDZW50dXJ5TGlua0RCYWFTMR0w\nGwYDVQQLDBRDZXJ0aWZpY2F0ZUF1dGhvcml0eTEbMBkGA1UEAwwSQ2VudHVyeUxp\nbmtEQmFhU0NBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzN5bNNjV\nGLZzq1vpGzgIDBdKzZtl625QSCVXu5vOGKZxsQDdMcflDylOPlOyJmg6t9KEkduQ\nKJvZhAoR03/ftqsYTNvzsbzyTraZb3fK7NZhbPLml9JLGrCeN0F3XmmYCKy+hoDA\nIegCOk4QazHu2XvVp/ATFc+w9jzEb6uHRrfvXtBPoGV3Td5tqfLEx+ZC9JAm6Ri3\n/eT8D+ys+sKYUyPPqJD12QN/ceWjvBrlCpyca2QoBb7OfZOZR8Q/xhxznYLsqBda\n4gWov23bGOVj9vSD/2kr9eSO+Ap739Awlso/hOjB/abDumsW9t1NPYSdscjxTD+t\n2EVcdGrvT5CT+QIDAQABo1AwTjAdBgNVHQ4EFgQULNhBKIj12kTyxWrg/hwMbtSk\nND4wHwYDVR0jBBgwFoAULNhBKIj12kTdxWrg/hwMbtSkND4wDAYDVR0TBAUwAwEB\n/zANBgkqhkiG9w0BAQsFAAOCAQEAbuEg3VquJxgg5exRtdgff9tWTozM0OozJc6d\noYgV11oH8NtvKLkwbChgGHKL1bXmMxTfW4vUk3FhuiO5S85oi0vvDGPq5gqM6oxr\ntbhaml7Nd0OoNCvRsGJiINKS3G8JRKmZ3+WA55wQEjZC5KuPlgB5XO418byYYDnc\n/k08pmEr8ztymAjVvc6rzlK0ZmUJqQnIEk+cDTHNYbALQwJ7+QZMbOGj1v/9w05M\nxFpTIBmySTP2+leCTP2qnJUiFc9yzfcMPQs6wS1KOOTwWS5LAqEUicZ17hCOMUi+\n1J1oVss1KdfPYfhSmbCbPg1ELwEHvnE7Bo4ildRlPGeSSb+gZw==\n-----END CERTIFICATE-----",
     "dbname": "default",
     "host": "66.151.15.159",
     "password": "MyPassword",
     "port": 49171,
     "username": "admin"
    },
    "label": "ctl_mysql",
    "name": "bab-mysql",
    "plan": "free",
    "tags": []
   }
  ]
 }
}
</pre>

This block of JSON includes information about the database name, username, password, and IP address of your service, and the information that you&#8217;ll need to connect to your service over SSL (more on this later). We&#8217;ll look at how we&#8217;ll parse that data shortly, but for now let&#8217;s look at this code taken from main.rb:

<pre class="brush: plain; title: ; notranslate" title="">vcap_services = ENV["VCAP_SERVICES"]

pem_file_path = &#039;./client_cert.pem&#039;

connection_string_model = DatabaseConnectionModel.FromCloudFoundryJson(vcap_services, pem_file_path)
ssl_certificate_file = SslCertificate.FromCloudFoundryJSON(vcap_services)
ssl_certificate_file.create_pem(pem_file_path)

set :connection_info, connection_string_model
</pre>

Most of it is pretty simple Ruby. The important parts are the last 4 lines, where we take the contents of the VCAP_SERVICES JSON and parse it into the connection string model using the `DatabaseConnectionModel` class, then take the data from the client certificate passed through the JSON and store it into a file.

This particular database library requires the certificate to be in a separate file, rather than just having the data passed into the hash for the connection string, so we have to create one using the `SslCertificateFile` class. This presents a potential issue when running on AppFog, because developers aren&#8217;t supposed to use the file system when running through CloudFoundry. When running on a Platform as a Service, like CloudFoundry, the file system is only temporary and is recreated from scratch each time an application is staged or moved by the PaaS to another server. But since our application recreates the file from the VCAP_SERVICES variable each time it starts, this should not be a problem for us at all.

## routes.rb

The other interesting class in our application is routes.rb, which is the class used by Sinatra to know how to route requests coming into the endpoint. Again, the code is pretty simple:

<pre class="brush: plain; title: ; notranslate" title="">get &#039;/&#039; do
  connection_string_model = settings.connection_info

  connection = Mysql2::Client.new(
      host: connection_string_model.host_name,
      port: connection_string_model.port,
      username: connection_string_model.user_id,
      password: connection_string_model.password,
      database: connection_string_model.database,
      sslca: connection_string_model.cert_file)

  results = connection.query("show status like &#039;Ssl_cipher&#039;")
  results.count.to_s
end
</pre>

It basically fills out the Mysql2 connection string with information parsed out of VCAP_SERVICES by the `DatabaseConnectionModel` and then makes a simple request to the server to validate that things worked. The last field of the connection string does bear a little talking about. First of all, be careful when implementing your own code &#8211; the appropriate field to fill in is `sslca`, not any of the others like `sslcert` or `sslkey`. What is sent to you when binding to the instance is a key that basically allows you to trust the self-signed certificate sent by the Database as a Service infrastructure, which is why you need to set the `sslca` field.

## The rest of the code

The rest of the code is really simple. It either pulls data out of JSON, creates and fills the PEM file with the appropriate information, or provides the boilerplate code needed by Sinatra. All of the code is available in the [github repository][6].

# Running the application in AppFog

Pushing an application to AppFog is really easy. Most of the important data needed is in the manifest.yml file:

<pre class="brush: plain; title: ; notranslate" title="">---
applications:
- name: bab-dbaas-test
  memory: 128M
  instances: 1
  services:
    - example-dbaas-instance
</pre>

The information in this file allows AppFog to stage and run your application with no further interaction with you. The name represents the unique label associated with your program &#8211; this name does have to be unique across the entire AppFog universe, so you&#8217;ll need to change it be something specific to you. And the name of the service, example-dbaas-instance in this case, has to match the name of the instance you created in the Preparing AppFog section from above. Other than that, it should be fine the way it is.

After you&#8217;ve made those changes, you can push the application by typing `cf push` from the same directory as the application on your file system. You&#8217;ll see a lot of lines fly by showing the different stages of launching the application. At the end of it, though, you should see a line that looks something like this:

<pre class="brush: plain; title: ; notranslate" title="">App started


OK

App bab-dbaas-test was started using this command `bundle exec rackup config.ru -p $PORT`

Showing health and status for app bab-dbaas-test in org T3OS / space Dev as brianbuttonxp...
OK

requested state: started
instances: 1/1
usage: 128M x 1 instances
urls: bab-dbaas-test.useast.appfog.ctl.io
last uploaded: Thu Sep 17 16:11:57 UTC 2015
stack: cflinuxfs2
buildpack: Ruby

     state     since                    cpu    memory          disk          details
#0   running   2015-09-17 11:12:26 AM   0.0%   63.3M of 128M   99.9M of 1G
</pre>

As long as the state above is `running`, you should be able to go to the URL listed in the `urls` line above and see any output. If you get any sort of error, like a 500 Internal Server errror, you can investigate it using standard CloudFoundry tools, such as `cf logs bab-dbaas-test`.

# Conclusion

It really is this easy to provision and consume a MySQL instance using Database as a Service. It only requires a small amount of CloudFoundry command line knowledge and basic knowledge of Ruby.

If anything is unclear or if you have a question, feel free to add an issue to the repo or contact me directly through this blog

&#8212; bab

 [1]: https://www.ctl.io
 [2]: https://www.ctl.io/knowledge-base/appfog/getting-started-with-appfog/
 [3]: https://github.com/cloudfoundry/cli
 [4]: https://www.ctl.io/knowledge-base/appfog/login-using-cf-cli/
 [5]: https://github.com/bbutton/DBaaSTest
 [6]: https://www.github.com/bbutton/DBaaSTest