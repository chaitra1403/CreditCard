Feature: Credit Card Collection Management System - Automated Notification and Workflow Processing

  # This feature validates the comprehensive credit card collection management system
  # including automated notifications, payment processing, collection workflows,
  # and regulatory compliance across multiple stages and communication channels

  Background:
    Given the collection management system is operational
    And the notification service is active
    And the security masking system is enabled for PII protection
    And regulatory compliance modules are configured

  @collection @notification @security
  Scenario Outline: Credit Card Due Reminder Generation with Security Masking
    Given a credit card account with number ending in "<card_last_four>"
    And the account status is "<account_status>"
    And the payment due date is <days_until_due> days from today
    And the outstanding balance is $<payment_amount>
    And notification preferences are set to "<communication_channels>"
    When the automated notification system triggers the due reminder process
    And the system generates the notification content
    Then the notification should be created successfully
    And the card number should be displayed as "****<card_last_four>"
    And the full credit card number should not be visible anywhere
    And the payment amount should show $<payment_amount>
    And the notification should be sent via "<communication_channels>"
    And the collection stage should be updated to "<collection_stage>"
    And the notification should comply with "<regulatory_requirement>"

    Examples:
      | card_last_four | account_status | days_until_due | payment_amount | communication_channels        | collection_stage    | regulatory_requirement |
      | 1234          | Active         | 3              | 250.00         | Email, SMS, Postal           | Pre-Due Reminder    | FDCPA Compliant       |
      | 5678          | Active         | 1              | 350.75         | Email, SMS                   | Pre-Due Reminder    | FDCPA Compliant       |
      | 9012          | Active         | 5              | 125.50         | Email, Postal                | Pre-Due Reminder    | FDCPA Compliant       |
      | 3456          | Active         | 7              | 500.00         | SMS, Phone Call              | Pre-Due Reminder    | FDCPA Compliant       |

  @collection @overdue @escalation
  Scenario Outline: Overdue Balance Alert Processing with Fee Calculations
    Given a credit card account with number ending in "<card_last_four>"
    And the account status is "<initial_status>"
    And the payment due date was <days_past_due> days ago
    And no payment has been received
    And the principal balance is $<principal_amount>
    And the interest rate is <interest_rate>%
    When the overdue balance alert system processes the account
    And the system calculates overdue fees and interest
    Then the overdue alert should be generated
    And the card number should display as "****<card_last_four>"
    And the full credit card number should remain masked
    And the total amount owed should be $<total_amount>
    And late fees of $<late_fee> should be applied
    And the account status should be updated to "<final_status>"
    And the collection stage should advance to "<collection_stage>"
    And alerts should be sent via "<communication_channels>"

    Examples:
      | card_last_four | initial_status | days_past_due | principal_amount | interest_rate | late_fee | total_amount | final_status | collection_stage      | communication_channels    |
      | 5678          | Active         | 1             | 250.00           | 24.99        | 25.50    | 275.50       | Overdue      | Initial Overdue Alert | Email, SMS, Phone Call    |
      | 2468          | Active         | 5             | 500.00           | 22.99        | 35.00    | 535.00       | Overdue      | Initial Overdue Alert | Email, SMS                |
      | 1357          | Active         | 10            | 800.00           | 26.99        | 45.00    | 845.00       | Overdue      | Initial Overdue Alert | Email, Phone Call, Postal |
      | 7890          | Active         | 15            | 300.00           | 24.99        | 30.00    | 330.00       | Overdue      | Initial Overdue Alert | All Channels              |

  @collection @delinquency @formal-notice
  Scenario Outline: Formal Collection Notice Generation for Delinquent Accounts
    Given a credit card account with number ending in "<card_last_four>"
    And the account is <days_past_due> days past due
    And the account status is "Delinquent"
    And the principal balance is $<principal>
    And accumulated interest is $<interest>
    And late fees total $<late_fees>
    And collection fees are $<collection_fees>
    When the formal collection notification system processes the account
    And legal compliance statements are included
    Then the formal collection notice should be generated
    And the card number should appear as "****<card_last_four>"
    And the full credit card number should be completely masked
    And the total claim amount should be $<total_claim>
    And all charges should be itemized correctly
    And the notice should include "<regulatory_requirement>" compliance statements
    And the notice should be delivered via "<delivery_method>"
    And the collection stage should be "<collection_stage>"

    Examples:
      | card_last_four | days_past_due | principal | interest | late_fees | collection_fees | total_claim | regulatory_requirement           | delivery_method          | collection_stage   |
      | 9012          | 60            | 1000.00   | 200.75   | 150.00    | 75.00          | 1425.75     | FDCPA Section 809 Validation    | Certified Mail, Email    | Formal Collection  |
      | 4567          | 75            | 1500.00   | 350.25   | 200.00    | 100.00         | 2150.25     | FDCPA Section 809 Validation    | Certified Mail           | Formal Collection  |
      | 8901          | 90            | 800.00    | 180.50   | 125.00    | 50.00          | 1155.50     | FDCPA Section 809 Validation    | Certified Mail, Email    | Formal Collection  |
      | 2345          | 120           | 2000.00   | 480.75   | 300.00    | 150.00         | 2930.75     | FDCPA Section 809 Validation    | Legal Service, Certified | Formal Collection  |

  @collection @payment-plan @structured-repayment
  Scenario Outline: Payment Plan Proposal Generation with Multiple Options
    Given a credit card account with number ending in "<card_last_four>"
    And the account is eligible for payment plans
    And the overdue balance is $<overdue_balance>
    And the original interest rate is <original_rate>%
    And the customer qualifies for reduced interest at <reduced_rate>%
    When the payment plan proposal system processes the account
    And payment options are calculated for <plan_duration> months
    Then the payment plan proposal should be generated
    And the card number should show "****<card_last_four>"
    And the full credit card number should be masked throughout
    And the monthly payment should be $<monthly_payment>
    And the reduced interest rate of <reduced_rate>% should apply
    And fee reductions should be calculated
    And the proposal should be delivered via "<delivery_channels>"
    And the collection stage should be "<collection_stage>"

    Examples:
      | card_last_four | overdue_balance | original_rate | reduced_rate | plan_duration | monthly_payment | delivery_channels     | collection_stage        |
      | 3456          | 2000.00        | 24.99         | 12.99        | 6             | 350.00         | Email, Postal Mail    | Payment Plan Proposal   |
      | 3456          | 2000.00        | 24.99         | 12.99        | 12            | 185.00         | Email, Postal Mail    | Payment Plan Proposal   |
      | 3456          | 2000.00        | 24.99         | 12.99        | 18            | 130.00         | Email, Postal Mail    | Payment Plan Proposal   |
      | 6789          | 1500.00        | 26.99         | 15.99        | 12            | 140.00         | Email                 | Payment Plan Proposal   |
      | 1234          | 3000.00        | 22.99         | 10.99        | 24            | 145.00         | Postal Mail           | Payment Plan Proposal   |

  @collection @legal-action @court-proceedings
  Scenario Outline: Legal Action Initiation with Documentation Preparation
    Given a credit card account with number ending in "<card_last_four>"
    And the account is <days_past_due> days past due
    And all previous collection stages have been completed
    And the total claim amount is $<total_claim>
    And legal fees are estimated at $<legal_fees>
    When the legal action system initiates court proceedings
    And legal documentation is prepared
    Then the legal action documentation should be generated
    And the card number should appear as "****<card_last_four>" in all legal documents
    And the full credit card number should never be exposed
    And the complete payment history should be documented
    And legal costs of $<legal_fees> should be included
    And the total claim should be $<final_claim_amount>
    And compliance with "<regulatory_requirement>" should be verified
    And service procedures should be initiated via "<service_method>"
    And the collection stage should be "<collection_stage>"

    Examples:
      | card_last_four | days_past_due | total_claim | legal_fees | final_claim_amount | regulatory_requirement                    | service_method              | collection_stage  |
      | 7890          | 150           | 3500.50     | 500.00     | 4000.50           | State Legal Action Requirements, FDCPA   | Legal Service, Certified    | Legal Proceedings |
      | 5432          | 180           | 2800.75     | 750.00     | 3550.75           | State Legal Action Requirements, FDCPA   | Legal Service               | Legal Proceedings |
      | 9876          | 200           | 4200.25     | 600.00     | 4800.25           | State Legal Action Requirements, FDCPA   | Legal Service, Certified    | Legal Proceedings |
      | 1357          | 165           | 1950.00     | 450.00     | 2400.00           | State Legal Action Requirements, FDCPA   | Certified Mail              | Legal Proceedings |

  @collection @agency-integration @data-transfer
  Scenario Outline: Collection Agency Integration and Secure Data Transfer
    Given a credit card account with number ending in "<card_last_four>"
    And the account is <days_past_due> days past due
    And internal collection efforts have failed
    And the balance is $<account_balance>
    When the collection agency assignment system processes the account
    And the appropriate agency "<collection_agency>" is selected
    And secure data transmission is initiated
    Then the account data should be transferred securely
    And the card number should be included as "****<card_last_four>"
    And the full credit card number should be encrypted and never transmitted in plain text
    And the data transfer should use "<encryption_protocol>"
    And the account status should be updated to "<new_status>"
    And transfer confirmation should be received
    And the collection stage should advance to "<collection_stage>"
    And compliance with "<regulatory_requirement>" should be maintained

    Examples:
      | card_last_four | days_past_due | account_balance | collection_agency           | encryption_protocol | new_status         | collection_stage          | regulatory_requirement           |
      | 4567          | 90            | 1800.25        | Premier Recovery Services   | AES-256 Encryption  | External Collection | Collection Agency Handoff | FDCPA Third-Party Disclosure    |
      | 2468          | 105           | 2200.50        | Advanced Recovery Solutions | AES-256 Encryption  | External Collection | Collection Agency Handoff | FDCPA Third-Party Disclosure    |
      | 8024          | 120           | 950.75         | Elite Collection Group      | AES-256 Encryption  | External Collection | Collection Agency Handoff | FDCPA Third-Party Disclosure    |
      | 3210          | 95            | 1375.00        | National Recovery Partners  | AES-256 Encryption  | External Collection | Collection Agency Handoff | FDCPA Third-Party Disclosure    |

  @collection @multi-channel @communication-workflow
  Scenario Outline: Multi-Channel Communication Delivery and Tracking
    Given a credit card account with number ending in "<card_last_four>"
    And the account is in collection stage "<collection_stage>"
    And communication preferences include "<preferred_channels>"
    And the outstanding balance is $<balance_amount>
    When the multi-channel communication system generates notifications
    And messages are prepared for all configured channels
    Then notifications should be delivered across "<delivery_channels>"
    And the card number should display consistently as "****<card_last_four>" across all channels
    And the full credit card number should be masked in all communication formats
    And delivery confirmations should be received for each channel
    And communication history should be updated
    And frequency regulations should be respected
    And the delivery status should show "<delivery_confirmation>"

    Examples:
      | card_last_four | collection_stage      | preferred_channels              | balance_amount | delivery_channels              | delivery_confirmation                                    |
      | 8901          | Multi-Channel         | Email, SMS, Postal, Phone       | 925.75         | Email, SMS, Postal Mail, Phone | Email Opened, SMS Delivered, Mail Tracking Active, Call Completed |
      | 5432          | Multi-Channel         | Email, SMS                      | 1250.00        | Email, SMS                     | Email Opened, SMS Delivered                              |
      | 7890          | Multi-Channel         | Postal, Phone                   | 800.50         | Postal Mail, Phone             | Mail Tracking Active, Call Completed                    |
      | 1234          | Multi-Channel         | Email, Postal                   | 1500.25        | Email, Postal Mail             | Email Opened, Mail Tracking Active                      |

  @collection @payment-plan @execution-workflow
  Scenario Outline: Payment Plan Execution and Automated Processing
    Given a credit card account with number ending in "<card_last_four>"
    And an accepted payment plan for $<plan_balance> over <plan_duration> months
    And monthly payments of $<monthly_payment>
    And reduced interest rate of <interest_rate>%
    And <payments_completed> payments have been completed
    When the payment plan execution system processes the next payment
    And automated payment processing is triggered
    Then the monthly payment should be processed successfully
    And the card number should appear as "****<card_last_four>" in payment confirmations
    And the full credit card number should remain protected
    And the remaining balance should be updated to $<remaining_balance>
    And payment plan progress should be tracked
    And the account status should be "<account_status>"
    And payment confirmation should be sent via "<communication_channels>"

    Examples:
      | card_last_four | plan_balance | plan_duration | monthly_payment | interest_rate | payments_completed | remaining_balance | account_status       | communication_channels |
      | 2345          | 2400.00      | 12            | 220.00          | 15.99         | 8                  | 880.00           | Payment Plan Active  | Email, SMS            |
      | 6789          | 1800.00      | 18            | 110.00          | 12.99         | 12                 | 660.00           | Payment Plan Active  | Email                 |
      | 3456          | 3000.00      | 24            | 145.00          | 18.99         | 20                 | 580.00           | Payment Plan Active  | SMS                   |
      | 9012          | 1200.00      | 12            | 105.00          | 14.99         | 11                 | 105.00           | Payment Plan Active  | Email, SMS            |

  @collection @status-management @lifecycle-transitions
  Scenario Outline: Account Status Transition Management Throughout Collection Lifecycle
    Given a credit card account with number ending in "<card_last_four>"
    And the current account status is "<current_status>"
    And the account has been in this status for <days_in_status> days
    And business rules are configured for status transitions
    When the status transition system evaluates the account
    And transition criteria are met for "<transition_trigger>"
    Then the account status should transition to "<new_status>"
    And the card number should remain consistently displayed as "****<card_last_four>"
    And the full credit card number should be protected throughout the transition
    And the collection stage should advance to "<new_collection_stage>"
    And status change notifications should be generated
    And a complete audit trail should be created with timestamp and reason
    And the transition should comply with business rules

    Examples:
      | card_last_four | current_status      | days_in_status | transition_trigger     | new_status          | new_collection_stage    |
      | 5432          | Current            | 1              | Payment Due Date      | Past Due            | Initial Past Due        |
      | 5432          | Past Due           | 30             | 30-Day Rule           | Delinquent          | Standard Delinquency    |
      | 5432          | Delinquent         | 60             | 60-Day Rule           | Serious Delinquency | Escalated Collection    |
      | 5432          | Serious Delinquency| 90             | 90-Day Rule           | Collection          | Active Collection       |
      | 5432          | Collection         | 30             | Customer Acceptance   | Payment Plan        | Structured Repayment    |
      | 5432          | Payment Plan       | 365            | Plan Completion       | Resolved            | Account Closed          |

  @collection @regulatory @compliance-validation
  Scenario Outline: Regulatory Compliance Validation Across All Collection Activities
    Given a credit card account with number ending in "<card_last_four>"
    And the account is subject to "<regulatory_requirement>" compliance
    And the customer is located in "<customer_jurisdiction>"
    And collection activities are in progress
    When the regulatory compliance system validates all collection processes
    And FDCPA validation notices are generated
    And state law compliance is checked
    Then all collection communications should include mandatory disclosures
    And the card number should comply with PII regulations showing "****<card_last_four>"
    And the full credit card number should never violate security regulations
    And the <validation_period>-day validation period should be honored
    And communication restrictions should be enforced
    And customer rights should be clearly stated including "<customer_rights>"
    And cease and desist functionality should be available
    And compliance status should be "<compliance_status>"

    Examples:
      | card_last_four | regulatory_requirement                 | customer_jurisdiction | validation_period | customer_rights                                           | compliance_status                           |
      | 6789          | FDCPA Section 809 Validation Notice   | Federal               | 30               | Dispute Process, Validation Request, Cease Communication  | Fully Compliant with Federal Requirements  |
      | 1357          | California Consumer Protection Laws    | California            | 30               | Enhanced Consumer Rights, Extended Validation            | Compliant with CA State Laws               |
      | 9876          | Texas Debt Collection Act              | Texas                 | 30               | State-Specific Rights, Local Validation                 | Compliant with TX State Laws               |
      | 2468          | New York Consumer Protection Laws      | New York              | 30               | NY Consumer Rights, Extended Protections                | Compliant with NY State Laws               |

  @collection @data-sync @agency-integration
  Scenario Outline: Real-time Data Synchronization Between Internal Systems and Collection Agencies
    Given a credit card account with number ending in "<card_last_four>"
    And the account is assigned to collection agency "<collection_agency>"
    And real-time synchronization is configured
    And the account balance is $<account_balance>
    When a payment of $<payment_amount> is received by the collection agency
    And customer communication is logged by the agency
    And account status changes are initiated
    Then payment updates should synchronize in real-time to internal systems
    And the card number should remain consistent as "****<card_last_four>" across all systems
    And the full credit card number should stay encrypted during all transfers
    And communication history should sync with internal records
    And the updated balance should be $<updated_balance>
    And data integrity checks should pass
    And audit trails should be synchronized across both systems
    And sync status should show "<sync_status>"

    Examples:
      | card_last_four | collection_agency           | account_balance | payment_amount | updated_balance | sync_status     |
      | 3210          | Advanced Recovery Solutions | 1375.00        | 200.00         | 1175.00        | Real-time Sync  |
      | 8024          | Premier Recovery Services   | 2200.50        | 500.00         | 1700.50        | Real-time Sync  |
      | 5678          | Elite Collection Group      | 950.25         | 150.00         | 800.25         | Real-time Sync  |
      | 9012          | National Recovery Partners  | 1800.75        | 300.00         | 1500.75        | Real-time Sync  |

  @collection @payment-processing @edge-cases
  Scenario Outline: Mid-Collection Payment Processing Edge Cases
    Given a credit card account with number ending in "<card_last_four>"
    And the account is <days_past_due> days past due
    And the collection stage is "<current_collection_stage>"
    And scheduled collection activities include "<scheduled_activity>"
    And the current balance is $<original_balance>
    When a customer payment of $<payment_amount> is received during active collection
    And the payment processing system handles the mid-collection payment
    Then the payment should be applied immediately to the outstanding balance
    And the card number should appear as "****<card_last_four>" in payment confirmations
    And the full credit card number should be protected during payment processing
    And the remaining balance should be updated to $<remaining_balance>
    And collection workflow should be "<workflow_action>"
    And the new collection strategy should be "<new_strategy>"
    And account status should be updated to "<updated_status>"

    Examples:
      | card_last_four | days_past_due | current_collection_stage | scheduled_activity        | original_balance | payment_amount | remaining_balance | workflow_action     | new_strategy              | updated_status    |
      | 9876          | 75            | Legal Preparation       | Legal Action Preparation  | 2200.00         | 800.00         | 1400.00          | Legal Action Halted | Resume Standard Collection | Payment Received  |
      | 5432          | 90            | Agency Assignment       | Collection Agency Transfer| 1500.00         | 1500.00        | 0.00             | Workflow Completed  | Account Resolved          | Paid in Full      |
      | 1234          | 60            | Formal Collection       | Legal Notice Preparation  | 1800.25         | 500.00         | 1300.25          | Process Adjusted    | Continue Collection       | Partial Payment   |
      | 7890          | 100           | Court Filing           | Court Document Preparation| 3000.50         | 1000.00        | 2000.50          | Filing Postponed    | Reassess Legal Action     | Payment Received  |

  @collection @templates @dynamic-content
  Scenario Outline: Dynamic Communication Template Management with Personalization
    Given a credit card account with number ending in "<card_last_four>"
    And customer profile indicates "<customer_segment>" status
    And preferred language is "<language_preference>"
    And customer location requires "<jurisdiction_compliance>" compliance
    And collection stage is "<collection_stage>"
    When the communication template system generates personalized content
    And regulatory-specific language is applied
    And accessibility requirements are implemented
    Then personalized notification content should be generated
    And the card number should be securely inserted as "****<card_last_four>"
    And the full credit card number should never be accessible to template system
    And content should be personalized for "<customer_segment>" customers
    And language should match "<language_preference>" preference
    And compliance should meet "<jurisdiction_compliance>" requirements
    And accessibility should meet "<accessibility_standard>" standards
    And template effectiveness should be optimized based on customer response history

    Examples:
      | card_last_four | customer_segment  | language_preference | jurisdiction_compliance      | collection_stage         | accessibility_standard |
      | 1357          | Premium Cardholder| English             | California Consumer Protection| Communication Optimization| WCAG 2.1 AA           |
      | 2468          | Standard Customer | Spanish             | Federal FDCPA                | Communication Optimization| WCAG 2.1 AA           |
      | 3579          | Business Customer | English             | Texas Debt Collection Act    | Communication Optimization| WCAG 2.1 AA           |
      | 4680          | Student Customer  | English             | New York Consumer Laws       | Communication Optimization| WCAG 2.1 AA           |

  @collection @calculations @financial-engine
  Scenario Outline: Complex Interest Rate and Fee Calculation Engine
    Given a credit card account with number ending in "<card_last_four>"
    And the account has been delinquent for <delinquency_days> days
    And the principal balance is $<principal_balance>
    And the standard interest rate is <standard_rate>%
    And penalty interest rate is <penalty_rate>%
    And late fees structure is configured
    When the financial calculation engine processes the account
    And compound interest is calculated for the delinquency period
    And penalty fees are applied based on collection stage
    Then interest should be calculated accurately using compound formulas
    And the card number should appear as "****<card_last_four>" in financial breakdowns
    And the full credit card number should never appear in calculation outputs
    And total accrued interest should be $<accrued_interest>
    And late fees should total $<total_late_fees>
    And collection fees should be $<collection_fees>
    And the total amount owed should be $<total_owed>
    And calculation accuracy should be verified with audit trail

    Examples:
      | card_last_four | delinquency_days | principal_balance | standard_rate | penalty_rate | accrued_interest | total_late_fees | collection_fees | total_owed |
      | 2468          | 90               | 2000.00          | 24.99         | 29.99        | 625.50          | 125.00          | 100.25          | 2850.75    |
      | 1357          | 60               | 1500.00          | 22.99         | 27.99        | 380.25          | 90.00           | 75.50           | 2045.75    |
      | 9876          | 120              | 3000.00          | 26.99         | 31.99        | 1250.75         | 200.00          | 150.00          | 4600.75    |
      | 5432          | 45               | 800.00           | 21.99         | 26.99        | 180.50          | 60.00           | 45.25           | 1085.75    |

  @collection @integration @cross-system-workflow
  Scenario Outline: End-to-End Cross-System Integration Workflow
    Given a credit card account with number ending in "<card_last_four>"
    And all collection systems are integrated and operational
    And the account requires complete lifecycle processing
    And current balance is $<account_balance>
    And integration systems include "<integrated_systems>"
    When the cross-system integration workflow initiates complete processing
    And data flows across all integrated platforms
    And status synchronization occurs in real-time
    Then account processing should occur seamlessly across all systems
    And the card number should appear consistently as "****<card_last_four>" across all systems
    And the full credit card number security should be maintained throughout all integrations
    And data flow should be synchronized with status "<data_flow_status>"
    And transaction tracing should provide "<traceability_level>" visibility
    And data integrity should be validated across all platforms
    And system uptime should meet SLA requirements
    And integration compliance should satisfy "<compliance_requirements>"

    Examples:
      | card_last_four | account_balance | integrated_systems                                          | data_flow_status | traceability_level    | compliance_requirements                    |
      | 8024          | 1950.25        | Notifications, Payments, Collection Agency, Legal, Portal  | Synchronized     | Complete End-to-End   | SOX, PCI DSS, FDCPA Cross-System         |
      | 5678          | 1200.75        | Notifications, Payments, Customer Portal                   | Synchronized     | Complete End-to-End   | PCI DSS, FDCPA Integration               |
      | 9012          | 2800.50        | Payments, Collection Agency, Legal System                  | Synchronized     | Complete End-to-End   | SOX, FDCPA Legal Integration             |
      | 3456          | 950.25         | Notifications, Customer Portal, Payment Processing         | Synchronized     | Complete End-to-End   | PCI DSS, Customer Privacy Compliance     |
