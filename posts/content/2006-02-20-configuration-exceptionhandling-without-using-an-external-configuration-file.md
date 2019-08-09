---
title: Configuration ExceptionHandling without using an external configuration file
author: Brian Button
type: post
date: 2006-02-20T08:34:00+00:00
url: /index.php/2006/02/20/configuration-exceptionhandling-without-using-an-external-configuration-file/
sfw_comment_form_password:
  - de75ExHt1PmB
sfw_pwd:
  - L9F87htiokJJ
categories:
  - 115

---
A couple of weeks ago, someone posted a question on the Enterprise Library GDN workspace, asking about how they could configure the Exception Handling block without using an external configuration file. I wrote a bit of code to do that, and I wanted to share it with everyone else.

Here is my solution. This first part is a very small change I made to ExceptionPolicy to allow it to accept an ExceptionPolicyFactory through an additional HandledException method.

<pre>//===============================================================================
// Microsoft patterns & practices Enterprise Library
// Exception Handling Application Block
//===============================================================================
// Copyright &copy; Microsoft Corporation. All rights reserved.
// Adapted from ACA.NET with permission from Avanade Inc.
// ACA.NET copyright &copy; Avanade Inc. All rights reserved.
// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE.
//===============================================================================

using System;
using System.Collections;
using System.Configuration;
using Microsoft.Practices.EnterpriseLibrary.Common.Configuration.ObjectBuilder;
using Microsoft.Practices.EnterpriseLibrary.Common.Instrumentation;
using Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Configuration;
using Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Properties;
using Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.Instrumentation;

namespace Microsoft.Practices.EnterpriseLibrary.ExceptionHandling
{
    /// &lt;summary>
    /// Represents a policy with exception types and
    /// exception handlers. 
    /// &lt;/summary>
    public static class ExceptionPolicy
    {
        private static readonly ExceptionPolicyFactory policyFactory = new ExceptionPolicyFactory();

        public static bool HandleException(Exception exceptionToHandle, string policyName)
        {
            return HandleException(exceptionToHandle, policyName, policyFactory);
        }

        public static bool HandleException(Exception exceptionToHandle, string policyName, ExceptionPolicyFactory factory)
        {
            if (exceptionToHandle == null) throw new ArgumentNullException("exceptionToHandle");
            if (factory == null) throw new ArgumentException("factory");
            if (string.IsNullOrEmpty(policyName)) throw new ArgumentException(Resources.ExceptionStringNullOrEmpty);

            ExceptionPolicyImpl policy = GetExceptionPolicy(exceptionToHandle, policyName, factory);

            return policy.HandleException(exceptionToHandle);
        }

        private static ExceptionPolicyImpl GetExceptionPolicy(Exception exception, string policyName, ExceptionPolicyFactory factory)
        {
            try
            {
                return factory.Create(policyName);
            }
            catch (ConfigurationErrorsException configurationException)
            {
                try
                {
                    DefaultExceptionHandlingEventLogger logger = EnterpriseLibraryFactory.BuildUp&lt;defaultexceptionhandlingeventlogger>();
                    logger.LogConfigurationError(configurationException, policyName);
                }
                catch { }
                throw;
            }

            catch (Exception ex)
            {
                try
                {
                    string exceptionMessage = ExceptionUtility.FormatExceptionHandlingExceptionMessage(policyName, ex, null, exception);

                    DefaultExceptionHandlingEventLogger logger = EnterpriseLibraryFactory.BuildUp&lt;defaultexceptionhandlingeventlogger>();
                    logger.LogInternalError(policyName, exceptionMessage);
                }
                catch { }

                throw new ExceptionHandlingException(ex.Message, ex);
            }
        }
    }
}
</pre>

And here is an example I took from the ExceptionHandling basic quickstart. If you take this code and put it in the QuickStartForm.Main method and adjust the constructor for AppService to take an ExceptionPolicyFactory, then you should have a complete example. I&rsquo;ve tried to indent the construction of the objects to make it more clear about what is being created and how it all gets hooked up. 

<pre>[STAThread]
static void Main()
{
    DictionaryConfigurationSource internalConfigurationSource = new DictionaryConfigurationSource();
        ExceptionHandlingSettings settings = new ExceptionHandlingSettings();
            NamedElementCollection&lt;exceptionpolicydata> policyData = settings.ExceptionPolicies;
                ExceptionPolicyData globalPolicyData = new ExceptionPolicyData("Global Policy");
                    NamedElementCollection&lt;exceptiontypedata> globalPolicyExceptionTypes = globalPolicyData.ExceptionTypes;
                        ExceptionTypeData exceptionType = new ExceptionTypeData("Exception", typeof(Exception), PostHandlingAction.None);
                            NameTypeConfigurationElementCollection&lt;exceptionhandlerdata> exceptionTypeHandlers = exceptionType.ExceptionHandlers;
                            exceptionTypeHandlers.Add(new CustomHandlerData("Custom Handler", typeof(AppMessageExceptionHandler)));
                    globalPolicyExceptionTypes.Add(exceptionType);
                ExceptionPolicyData handleAndResumeData = new ExceptionPolicyData("Handle and Resume Policy");
                    NamedElementCollection&lt;exceptiontypedata> handleAndResumeExceptionTypes = handleAndResumeData.ExceptionTypes;
                    handleAndResumeExceptionTypes.Add(exceptionType);
                ExceptionPolicyData propagatePolicyData = new ExceptionPolicyData("Propagate Policy");
                    NamedElementCollection&lt;exceptiontypedata> propagatePolicyExceptionTypes = propagatePolicyData.ExceptionTypes;
                        ExceptionTypeData exceptionWithRethrowType = new ExceptionTypeData("Exception", typeof(Exception), PostHandlingAction.NotifyRethrow);
                    propagatePolicyExceptionTypes.Add(exceptionWithRethrowType);
                ExceptionPolicyData replacePolicyData = new ExceptionPolicyData("Replace Policy");
                    NamedElementCollection&lt;exceptiontypedata> replacePolicyExceptionTypes = replacePolicyData.ExceptionTypes;
                        ExceptionTypeData securityExceptionType = new ExceptionTypeData("SecurityException", typeof(SecurityException), PostHandlingAction.ThrowNewException);
                            NameTypeConfigurationElementCollection&lt;exceptionhandlerdata> securityExceptionTypeHandlers = securityExceptionType.ExceptionHandlers;
                            securityExceptionTypeHandlers.Add(new ReplaceHandlerData("Replace Handler", "Replaced Exception: User is not authorized to peform the requested action.", typeof(ApplicationException)));
                    replacePolicyExceptionTypes.Add(securityExceptionType);
                ExceptionPolicyData wrapPolicyData = new ExceptionPolicyData("Wrap Policy");
                    NamedElementCollection&lt;exceptiontypedata> wrapPolicyExceptionTypes = wrapPolicyData.ExceptionTypes;
                        ExceptionTypeData dbConcurrencyExceptionType = new ExceptionTypeData("DBConcurrencyException", typeof(DBConcurrencyException), PostHandlingAction.ThrowNewException);
                            NameTypeConfigurationElementCollection&lt;exceptionhandlerdata> dbConcurrencyExceptionTypeHandlers = dbConcurrencyExceptionType.ExceptionHandlers;
                            dbConcurrencyExceptionTypeHandlers.Add(new WrapHandlerData("Wrap Handler", "Wrapped Exception: A recoverable error occurred while attempting to access the database.", typeof(BusinessLayerException)));
                    wrapPolicyExceptionTypes.Add(dbConcurrencyExceptionType);
                  
                policyData.Add(globalPolicyData);
                policyData.Add(handleAndResumeData);
                policyData.Add(propagatePolicyData);
                policyData.Add(replacePolicyData);
                policyData.Add(wrapPolicyData);

        internalConfigurationSource.Add(ExceptionHandlingSettings.SectionName, settings);
        policyFactory = new ExceptionPolicyFactory(internalConfigurationSource);

    AppForm = new QuickStartForm();
    Application.Run(AppForm);
}

<font face="Times New Roman">If this example isn&rsquo;t clear to you, please let me know, and I can try to answer any questions that any of you may still have.</font></pre>

<pre><font face="Times New Roman">&mdash; bab</font></pre>

<pre>&nbsp;</pre>