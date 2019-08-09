---
title: Running the Enterprise Library Unit Tests
author: Brian Button
type: post
date: 2005-04-07T10:09:00+00:00
url: /index.php/2005/04/07/running-the-enterprise-library-unit-tests/
sfw_comment_form_password:
  - 4sjTsGYzghHz
sfw_pwd:
  - ZajJQIhJ8KWT
categories:
  - 115

---
One of the biggest secrets of Enterprise Library is that we shipped it with 1800 NUnit unit tests. These tests reflect our best efforts to write this code in an agile, Test-Driven style. Sometimes we were more successful than others, but the fact remains, we did a damn good job of writing tests for our code.

**What do the unit tests do for me?**

As a developer, these unit tests are a great resource. First and foremost, they tell you whether or not Enterprise Library is working. These tests should run all the time at 100% success (give or take a few that are timing dependent &mdash; our fault&hellip;). They also serve as excellent examples of how Enterprise Library works. Have a question about how to pass parameters to a stored procedure using Oracle? Well, my friend, there is a unit test that we wrote that does that exact thing, and you can look at it and see exactly how it works!

The tricky part is that these tests are undocumented, and the process of getting them to run is undocumented. So, here is my best shot at telling you how to get our tests to run. If I&rsquo;ve missed anything, or something is unclear, please let me know, and I&rsquo;ll update this page.

The instructions:

  1. Install Visual Studio .Net 2003
  2. Install either MSDE or SqlServer (Oracle and DB2 are optional)
  3. Install MSMQ
  4. Install .Net framework 1.1
  5. Install NUnit 2.1.4
  6. Download and install Enterprise Library. You don&rsquo;t need to compile it at this point, as we&rsquo;ll do it manually shortly.
  7. Start Visual Studio and open EnterpriseLibrary.sln
  8. Change build target from Debug to DebugUnitTests
  9. Rebuild solution
 10. Open a visual studio command prompt and navigate to c:Program FilesMicrosoft Enterprise LibrarysrcCommonInstrumentationScripts. Run this command without the quotes: &ldquo;InstallInstrumentation.cmd DebugTests&rdquo;
 11. Run the following scripts from the given directories:
  * srcCachingScripts &ndash; CreateCachingDb.cmd
  * srcLoggingSinksDatabaseScripts &ndash; CreateLoggingDatabase.cmd
  * srcSecurityDatabaseScripts &mdash; CreateSecurityDatabase.cmd

 12. Open &ldquo;C:program filesnunit-2.1binnunit-gui.exe&rdquo;
 13. File->Open and navigate to the assembly you want to test. Quick word of warning &mdash; Many of our unit tests use custom configuration files to provide the test setup that they need. You can only run the tests for an assembly in that assembly&rsquo;s &ldquo;home&rdquo; directory. For example, you can only open and test Microsoft.Practices.EnterpriseLibrary.Caching.Database.dll in the srcCachingDatabasebinDebugTests directory, because that is where its configuration lives.

**NOTES:**

  * &nbsp;Data &mdash; 56 tests will fail if you do not have Oracle installed. If you do happen to have oracle installed, you&rsquo;ll need to manually open the DataTestsTestConfigurationContext.cs file and change your oracle connection settings.
  * Logging &mdash; EmailSinkFixture.LogMessageToEmail will fail, since you do not have access to our internal mail server. You can fix this by changing LoggingTestsEnterpriseLibrary.LoggingDistributor.config on line 22 to reference different smtpServers and to and from addresses.
  * Security.ActiveDirectory &mdash; Tests will fail because you cannot access our Active Directory server. There are instructions about how to set up ADAM in Security.ActiveDirectory.Configuration.ADAM Setup. You&rsquo;ll also need to change line 53 in Security.ActiveDirectory.Tests.TestConfigurationContext to reflect your ADAM setup.
  * EnterpriseLibrary &mdash; It is normal for several of the tests to occasionally fail. There are a few unit tests that are timing-dependent, especially in Caching and Configuration. These tests are testing whether or not something happens during a particular time interval, and sometimes the system delays the actions too long and those tests fail. If you rerun the test, it should work the next time. Additionally, our tests write to the event log, which occasionally fills up. If you begin to see a number of tests failing, check that your application event log is not full.