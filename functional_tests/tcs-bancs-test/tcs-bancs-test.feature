Feature: Call Centre Trading Terminal - Login, Customer Authentication, Trading, Orders, Widgets, Reports, Market View, Transfers and Compliance

  # Notes:
  # - Requirements are predominantly UI workflow and UI validation; scenarios are generated as UI tests only.
  # - SSO dependencies are validated via UI-visible SSO layer branding/redirect behavior (no API calls in UI scenarios).
  # - Where data seeding is required (orders/holdings/CA/exceptions), scenarios assume synthetic seeded datasets exist.

  Background:
    Given I am using a supported web browser

  # -----------------------------
  # UI Tests - Login & SSO
  # -----------------------------
  @ui @critical @p0
  Scenario: Login via browser URL presents logon screen through SSO layer and refresh keeps user at logon
    Given I have a clean browser session with no active application session
    When I navigate to the application URL
    Then I should see the logon screen
    And I should see an SSO-branded login layer as part of the login journey
    When I refresh the browser page
    Then I should still see the logon screen

  @ui @critical @p0
  Scenario Outline: Login screen supports Hebrew and English language selection and updates labels
    Given I have a clean browser session with no active application session
    When I navigate to the application URL
    Then I should see the logon screen
    When I open the language selector
    Then I should see language options including 'Hebrew' and 'English'
    When I select '<language>'
    Then the logon screen labels should be displayed in '<language>'

    Examples:
      | language |
      | English  |
      | Hebrew   |

  @ui @p1
  Scenario Outline: Keyboard navigation on logon screen supports TAB forward and SHIFT+TAB backward
    Given I have a clean browser session with no active application session
    When I navigate to the application URL
    Then I should see the logon screen
    When I click into the 'Login ID' field
    And I press the '<forward_key>' key
    Then focus should move to the next interactive element on the logon screen
    When I press the '<backward_key>' key
    Then focus should move to the previous interactive element on the logon screen
    And I should be able to reach the 'Login' action control using only keyboard navigation

    Examples:
      | forward_key | backward_key |
      | TAB         | SHIFT+TAB    |

  @ui @p1
  Scenario: First-time login uses default password provided by admin and navigates to Customer Authentication
    Given I navigate to the application URL
    And I should see the logon screen
    When I enter 'cc_first_01' in the 'Login ID' field
    And I enter 'TempPwd#12345' in the 'Password' field
    And I select 'English' from the language selector
    And I click the 'Login' button
    Then I should be authenticated through the SSO layer
    And I should see the 'Customer Authentication' screen

  @ui @p2
  Scenario: Pressing ENTER submits login and navigates to Customer Authentication
    Given I navigate to the application URL
    And I should see the logon screen
    When I enter 'cc_user_01' in the 'Login ID' field
    And I enter 'Pwd#12345!' in the 'Password' field
    And I select 'English' from the language selector
    And I focus the 'Password' field
    And I press the 'ENTER' key
    Then I should see the 'Customer Authentication' screen

  @ui @critical @p0
  Scenario: Successful login shows Customer Authentication screen with authentication controls
    Given I navigate to the application URL
    When I log in with valid call centre credentials through SSO
    Then I should see the 'Customer Authentication' screen
    And I should see 'Service Mode' control
    And I should see 'Identification Type' control
    And I should see 'Identification Number' field
    And I should see an 'Authenticate' action control

  # -----------------------------
  # UI Tests - Customer Authentication & Portfolio Selection
  # -----------------------------
  @ui @critical @p0
  Scenario Outline: Customer Authentication Service Mode supports Phone, Fax, Email
    Given I log in with valid call centre credentials through SSO
    And I should see the 'Customer Authentication' screen
    When I open the 'Service Mode' options
    Then I should see an option '<service_mode>'
    When I select '<service_mode>' from 'Service Mode'
    Then 'Service Mode' should display '<service_mode>'

    Examples:
      | service_mode |
      | Phone        |
      | Fax          |
      | Email        |

  @ui @critical @p0
  Scenario Outline: Authenticate customer by Identification Type and Identification Number shows Portfolio List and allows Submit
    Given I log in with valid call centre credentials through SSO
    And I should see the 'Customer Authentication' screen
    When I select 'Phone' from 'Service Mode'
    And I select '<id_type>' from 'Identification Type'
    And I enter '<id_number>' in the 'Identification Number' field
    And I click the 'Authenticate' button
    Then I should see the 'Portfolio List' screen
    And I should see a portfolio list with reference numbers
    When I select the first portfolio row
    And I click the 'Submit' button
    Then the workflow should proceed beyond 'Portfolio List'

    Examples:
      | id_type      | id_number  |
      | National Id  | 999999999  |
      | Passport Id  | P-TEST-123 |

  @ui @p1
  Scenario Outline: Authenticate customer by Portfolio Reference Number shows Portfolio List and allows Submit
    Given I log in with valid call centre credentials through SSO
    And I should see the 'Customer Authentication' screen
    When I select 'Email' from 'Service Mode'
    And I leave 'Identification Type' empty
    And I leave 'Identification Number' empty
    And I enter '<portfolio_reference>' in the 'Portfolio Reference Number' field
    And I click the 'Authenticate' button
    Then I should see the 'Portfolio List' screen
    When I select the first portfolio row
    And I click the 'Submit' button
    Then the workflow should proceed beyond 'Portfolio List'

    Examples:
      | portfolio_reference |
      | PRN-TEST-000123     |
      | PRN-TEST-000999     |

  @ui @p2
  Scenario: Reset clears Customer Authentication inputs
    Given I log in with valid call centre credentials through SSO
    And I should see the 'Customer Authentication' screen
    When I select 'Fax' from 'Service Mode'
    And I select 'Passport Id' from 'Identification Type'
    And I enter 'P-TEST-123456' in the 'Identification Number' field
    And I enter 'PRN-TEST-000999' in the 'Portfolio Reference Number' field
    And I click the 'Reset' button
    Then 'Service Mode' should be empty or default
    And 'Identification Type' should be empty or default
    And 'Identification Number' should be empty
    And 'Portfolio Reference Number' should be empty

  @ui @critical @p0
  Scenario: Portfolio List displays linked portfolios and requires selection before Submit
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer with valid identification details
    Then I should see the 'Portfolio List' screen
    And I should see multiple portfolio rows for the search
    When I click the 'Submit' button without selecting a portfolio
    Then I should see a validation message indicating a portfolio selection is required
    When I select the first portfolio row
    And I click the 'Submit' button
    Then I should see the 'Integrated Login' screen

  # -----------------------------
  # UI Tests - Integrated Login & Trading Navigation
  # -----------------------------
  @ui @p1
  Scenario Outline: Integrated login requires selecting Trading from three options to reach Trading screen
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and submit a portfolio
    When I should see the 'Integrated Login' screen
    Then I should see exactly three integrated login options
    When I select '<option>'
    And I continue from the integrated login selection
    Then I should see the '<expected_screen>' screen

    Examples:
      | option  | expected_screen |
      | Trading | Trading         |

  @ui @p1
  Scenario Outline: Trading screen shows tiles and opens functions by clicking tiles
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and submit a portfolio
    And I select 'Trading' in the integrated login screen
    When I should see the 'Trading' screen
    Then I should see functionality tiles on the Trading screen
    When I click the '<tile>' tile
    Then I should see the '<target>' screen
    When I navigate back to the Trading screen
    Then I should see functionality tiles on the Trading screen

    Examples:
      | tile      | target    |
      | Dashboard | Dashboard |

  @ui @p1
  Scenario: Menu bar contains required top-level menus and each is clickable
    Given I log in with valid call centre credentials through SSO
    When I load the main terminal interface
    Then I should see the menu bar
    And I should see menu item 'Home'
    And I should see menu item 'Market View'
    And I should see menu item 'Orders'
    And I should see menu item 'Account & Portfolio'
    And I should see menu item 'Reports'
    And I should see menu item 'Research & News'
    And I should see menu item 'Injob Activities'
    When I click 'Home' in the menu bar
    Then the 'Home' menu section should open
    When I click 'Market View' in the menu bar
    Then the 'Market View' menu section should open
    When I click 'Orders' in the menu bar
    Then the 'Orders' menu section should open
    When I click 'Account & Portfolio' in the menu bar
    Then the 'Account & Portfolio' menu section should open
    When I click 'Reports' in the menu bar
    Then the 'Reports' menu section should open
    When I click 'Research & News' in the menu bar
    Then the 'Research & News' menu section should open
    When I click 'Injob Activities' in the menu bar
    Then the 'Injob Activities' menu section should open

  @ui @p2
  Scenario: Title area shows Bank Name and logged-in call centre user name and persists after refresh
    Given I log in with valid call centre credentials through SSO
    When I load the terminal UI
    Then I should see the title area
    And the title area should display the bank name
    And the title area should display the logged-in user name
    When I refresh the browser page
    Then I should see the title area
    And the title area should display the bank name
    And the title area should display the logged-in user name

  @ui @p2
  Scenario Outline: Toolbar navigation opens key functions
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I locate the toolbar
    And I click the '<toolbar_button>' toolbar button
    Then I should see the '<expected_screen>' screen

    Examples:
      | toolbar_button           | expected_screen           |
      | Mutual fund              | Mutual Funds              |
      | Buy/Sell order entry     | Order Entry               |

  # -----------------------------
  # UI Tests - Access rules (customer context vs non-customer context)
  # -----------------------------
  @ui @critical @p0
  Scenario Outline: Non-customer functions are accessible without selecting customer
    Given I log in with valid call centre credentials through SSO
    And I do not authenticate a customer
    When I open '<function>' from navigation
    Then I should see the '<screen>' screen
    And I should confirm no customer authentication step was performed

    Examples:
      | function                     | screen          |
      | Dashboard                    | Dashboard       |
      | Market View > Market Watch   | Market Watch    |
      | Injob Activities             | Injob Activities|
      | Research & News > News       | News            |

  @ui @critical @p0
  Scenario Outline: Customer-specific activities require customer authentication
    Given I log in with valid call centre credentials through SSO
    And I do not authenticate a customer
    When I attempt to access '<customer_specific_function>'
    Then I should see a message indicating customer authentication is required
    When I authenticate a customer and submit a portfolio and enter Trading
    And I attempt to access '<customer_specific_function>'
    Then I should be allowed to access '<expected_screen>'

    Examples:
      | customer_specific_function         | expected_screen |
      | Orders > Order Entry               | Order Entry     |
      | Orders > Order Book                | Order Book      |
      | Trade Book                         | Trade Book      |

  # -----------------------------
  # UI Tests - Dashboard & Widgets configuration
  # -----------------------------
  @ui @critical @p0
  Scenario: Open Dashboard from Trading screen after completing login steps
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and submit a portfolio
    And I select 'Trading' in the integrated login screen
    When I click the 'Dashboard' tile
    Then I should see the 'Dashboard' screen

  @ui @p1
  Scenario: Dashboard shows six widgets at a time and supports configuration from list
    Given I am on the 'Dashboard' screen
    When I count the widgets visible on the dashboard
    Then I should see at most 6 widgets visible at a time
    When I open the 'Add Widget' list
    Then I should see a list of available widgets
    When I select a widget not currently on the dashboard and add it
    Then the widget should appear on the dashboard
    And I should still see at most 6 widgets visible at a time

  @ui @p1
  Scenario: Add Widget prevents selecting already added widget and allows selecting non-added widget
    Given I am on the 'Dashboard' screen
    And I identify a widget currently present on the dashboard
    When I open the 'Add Widget' list
    Then the already-present widget should be disabled or not selectable
    When I select a widget not currently on the dashboard and add it
    Then the newly selected widget should appear on the dashboard
    When I open the 'Add Widget' list again
    Then the newly added widget should be disabled or not selectable

  @ui @p2
  Scenario: Remove widget using Close and then re-add from Add Widget list
    Given I am on the 'Dashboard' screen
    And I select a widget that has a 'Close' control
    When I click 'Close' on that widget
    Then the widget should no longer be visible on the dashboard
    When I open the 'Add Widget' list
    And I select the removed widget
    And I add it
    Then the widget should be visible again on the dashboard

  @ui @p2
  Scenario: Reorder widgets by moving within widget window frame and restore original order
    Given I am on the 'Dashboard' screen
    And I have at least two widgets visible
    When I drag widget 'A' to the position of widget 'B' within the widget frame
    Then the widgets order should reflect the new placement
    When I drag widget 'A' back to its original position
    Then the widgets order should match the original ordering

  @ui @p2
  Scenario: Save widgets layout using Widgets Layout checkbox in Settings and verify persistence after relogin
    Given I am on the 'Dashboard' screen
    And I have at least two widgets visible
    When I reorder two widgets to create a new layout
    And I open 'Settings'
    And I check the 'Widgets Layout' checkbox
    And I close 'Settings'
    Then the dashboard should retain the reordered layout in the current session
    When I log out
    And I log in with the same user through SSO
    And I navigate to the 'Dashboard' screen
    Then I should see the previously saved widgets layout

  @ui @p2
  Scenario: Widget header controls (Help/Refresh/Close/Maximize) are present for applicable widgets and operate
    Given I am on the 'Dashboard' screen
    When I inspect the header of a widget
    Then I should see one or more controls among 'Help', 'Refresh', 'Close', 'Maximize' where applicable
    When I click 'Help' on a widget that supports Help
    Then I should see a help panel or help content for that widget
    When I click 'Refresh' on a widget that supports Refresh
    Then the widget content should reload or re-render
    When I click 'Maximize' on a widget that supports Maximize
    Then the widget should open in an expanded view
    When I restore the widget view
    Then I should return to the dashboard widget view

  # -----------------------------
  # UI Tests - Market Watch & Quotes Widgets
  # -----------------------------
  @ui @p1
  Scenario: Linked Quote widget updates when highlighting a Market Watch row and shows top 5 bids/offers
    Given I am on the 'Dashboard' screen
    And I can see the 'Market Watch' area
    And I can see the 'Linked Quote' widget
    When I highlight the first security row in Market Watch
    Then the Linked Quote widget should update to the highlighted security
    And the Linked Quote widget should show 5 best bids and 5 best offers
    When I highlight a different security row in Market Watch
    Then the Linked Quote widget should update to the newly highlighted security
    And the Linked Quote widget should show 5 best bids and 5 best offers

  @ui @critical @p1
  Scenario Outline: Quotes widget requires minimum characters before showing suggestion list and supports refresh
    Given I am on the 'Dashboard' screen
    And I can see the 'Quotes' widget
    When I type '<typed_value>' in the Quotes widget security input
    Then the symbol suggestion list '<suggestion_state>' be available
    When I type '<min_value>' in the Quotes widget security input
    Then the symbol suggestion list should be available
    When I select a security from the suggestion list
    Then the Quotes widget should display 5 best bids and 5 best offers for the selected security
    When I click 'Refresh' on the Quotes widget
    Then the Quotes widget details should reload for the same selected security

    Examples:
      | typed_value | suggestion_state | min_value |
      | A           | should not       | ABC       |

  @ui @p2
  Scenario: Charts widget supports magnify by dragging and Maximize/Restore
    Given I am on the 'Dashboard' screen
    And I can see the 'Charts' widget
    When I search and select a security in the Charts widget
    Then I should see an intra-day chart for the selected security
    When I drag across a time interval on the chart
    Then the chart should magnify the selected interval
    When I click 'Maximize' on the Charts widget
    Then I should see an expanded chart view with intraday and historical options
    When I click 'Restore'
    Then I should return to the dashboard widget view

  @ui @p2
  Scenario: Account & Portfolio widget displays currency, net balance, available balance and supports Refresh
    Given I am on the 'Dashboard' screen
    And I can see the 'Account & Portfolio' widget
    When I view the widget content
    Then I should see 'Account currency'
    And I should see 'Net balance'
    And I should see 'Available balance'
    When I click 'Refresh' on the Account & Portfolio widget
    Then the widget content should reload without error

  @ui @p1
  Scenario: Order Book widget shows pending orders and supports actions and refresh
    Given I am on the 'Dashboard' screen
    And I can see the 'Order Book' widget
    When I view the widget list
    Then I should see pending order details for the current date if pending orders exist
    When I click 'Refresh' on the Order Book widget
    Then the Order Book widget should reload its list
    When I click 'Maximize' on the Order Book widget if available
    Then I should see an expanded order book view with additional attributes

  @ui @p2
  Scenario: Trade Book widget shows current-date trades and supports Maximize
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading and open Dashboard
    When I locate the 'Trade Book' widget
    Then it should show current-date trade rows for the selected account if trades exist
    When I click 'Maximize' on the Trade Book widget
    Then I should see a detailed Trade Book view for the same account

  @ui @p2
  Scenario: Top Gainers and Losers widget is visible and displays LTP-based gainers/losers
    Given I log in with valid call centre credentials through SSO
    And I enter Trading and open Dashboard
    When I locate the 'Top Gainers and Losers' widget
    Then I should see lists of gainers and losers
    And the widget should display LTP or LTP-derived movement context

  @ui @p2
  Scenario: Major Indices widget supports '+' intraday chart, Maximize to Index Watch and Refresh
    Given I log in with valid call centre credentials through SSO
    And I enter Trading and open Dashboard
    When I locate the 'Major Indices' widget
    Then I should see a list of indices
    When I click '+' for an index row
    Then I should see an intraday chart for that index
    When I click 'Maximize' on the Major Indices widget
    Then I should see the 'Index Watch' screen
    When I return to Dashboard and click 'Refresh' on Major Indices
    Then the indices list should reload

  @ui @p2
  Scenario: Exchange News widget shows headlines with date/time/link and Maximize
    Given I log in with valid call centre credentials through SSO
    And I enter Trading and open Dashboard
    When I locate the 'Exchange News' widget
    Then I should see at least one headline with date and time
    And I should see a link to view the complete news
    When I click 'Maximize' on the Exchange News widget
    Then I should see an expanded News view with additional attributes

  @ui @p2
  Scenario: Messages widget shows Admin messages with date/time and supports Maximize and Refresh
    Given I log in with valid call centre credentials through SSO
    And I enter Trading and open Dashboard
    When I locate the 'Messages' widget
    Then I should see messages from Admin with date and time
    When I click 'Maximize' on the Messages widget
    Then I should see the full 'Messages' functionality
    When I return to Dashboard and click 'Refresh' on the Messages widget
    Then the message list should reload

  # -----------------------------
  # UI Tests - Equity Order Entry and Pre-Order Alerts
  # -----------------------------
  @ui @critical @p0
  Scenario Outline: Pre-order check Error blocks proceeding until addressed
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I enter valid required order fields to enable 'Place Order'
    And I click 'Place Order'
    Then I should see an order alerts dialog with an '<alert_type>' alert
    And I should not be able to proceed to the next phase while the '<alert_type>' exists

    Examples:
      | alert_type |
      | Error      |

  @ui @critical @p0
  Scenario Outline: Pre-order check Warning requires Yes to continue and No to discontinue
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I enter required order fields to enable 'Place Order'
    And I click 'Place Order'
    Then I should see an order alerts dialog with a 'Warning' alert and 'Yes' and 'No' options
    When I choose '<choice>'
    Then the order flow '<expected_outcome>'

    Examples:
      | choice | expected_outcome                        |
      | No     | should discontinue and not proceed       |
      | Yes    | should continue to the next phase        |

  @ui @p1
  Scenario: Pre-order check Information is display-only and does not require user input
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I enter required order fields to enable 'Place Order'
    And I click 'Place Order'
    Then I should see an order alerts dialog with an 'Information' message
    And the Information message should not require a Yes/No decision

  @ui @critical @p0
  Scenario: Equity order placement follows Create -> Preview -> Confirmation phases
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I open 'Orders' > 'Order Entry'
    Then I should see the 'Create' phase
    When I enter valid symbol, exchange, quantity and price
    And I click 'Place Order'
    Then I should see the 'Preview' phase with order details
    When I check 'I Agree for Commission & Order'
    And I click 'Buy' to confirm
    Then I should see the 'Confirmation' phase
    And I should see an internal order number

  @ui @p1
  Scenario: Open Order Entry from Orders menu opens Create phase
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I click 'Orders' in the menu bar
    And I click 'Order Entry'
    Then I should see the 'Order Entry' screen
    And I should see the 'Create' phase as the initial step

  @ui @p1
  Scenario: Invoke Order Entry from Market Watch buy/sell symbol
    Given I log in with valid call centre credentials through SSO
    And I do not authenticate a customer
    When I open 'Market View' > 'Market Watch'
    Then I should see a list of securities with a buy/sell symbol
    When I click the buy/sell symbol for a security row
    Then I should see the 'Order Entry' screen or panel
    And I should see 'Symbol' and 'Exchange' fields for order entry
    When I close the order entry panel
    Then I should return to the 'Market Watch' screen

  @ui @p2
  Scenario: Invoke Order Entry from left toolbar buy/sell symbol
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I click the buy/sell symbol on the left toolbar
    Then I should see the 'Order Entry' screen or panel
    And I should see an order creation context

  @ui @critical @p0
  Scenario: Advisory buy order allows entering Symbol, Exchange and Advisory Number without placing order
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I open 'Orders' > 'Order Entry'
    And I enter a valid 'Symbol'
    And I select a valid 'Exchange'
    And I enter 'ADV-TEST-000123' in the 'Advisory Number' field
    Then the advisory number should remain populated
    When I close the order entry screen without placing the order
    Then I should not see a confirmation screen or internal order number

  @ui @critical @p0
  Scenario: Symbol selection uses first three characters and dropdown; Level 1 quotes and Get Quote appear
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I type 'ABC' into the 'Symbol' field
    Then I should see a symbol dropdown suggestion list
    When I select a symbol from the dropdown
    Then I should see Level 1 quote components on the order entry screen
    And I should see a 'Get Quote' control on the order entry screen
    When I clear the Symbol field and type 'AB'
    Then I should not be able to complete symbol selection via the dropdown method

  @ui @p1
  Scenario: Level 2 quote opens via book icon on Order Entry
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I click the book icon
    Then I should see a Level 2 quote view
    When I close the Level 2 quote view
    Then I should return to the order entry screen

  @ui @p2
  Scenario: Refresh reloads Level 1 quotes on Order Entry
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I record the current 'As on Date' or a visible quote field value
    And I click 'Refresh' on the order entry screen
    Then the Level 1 quotes section should reload

  @ui @p1
  Scenario: Principal Account and Fee Account appear for single cash account
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer with a single cash account and enter Trading
    When I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    Then I should see 'Principal Account' field
    And I should see 'Fee Account' field

  @ui @p1
  Scenario Outline: Amount currency is based on security type (ILS or USD) and Amount/Quantity/Price accept input
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I select '<security_type>' security by symbol and exchange
    Then the 'Amount' currency indicator should display '<currency>'
    When I enter '<amount>' in 'Amount'
    And I enter '<quantity>' in 'Quantity'
    And I enter '<price>' in 'Price'
    Then the order entry fields should accept the values

    Examples:
      | security_type | currency | amount | quantity | price |
      | ILS           | ILS      | 1000   | 10       | 50    |
      | USD           | USD      | 100    | 5        | 20    |

  @ui @critical @p0
  Scenario: Quantity Type Disclosed enables initial/additional disclosed quantity fields
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I select 'Disclosed' in 'Quantity Type'
    Then 'Initial disclosed quantity' should be enabled
    And 'Additional disclosed quantity' should be enabled
    When I enter '100' in 'Initial disclosed quantity'
    And I enter '50' in 'Additional disclosed quantity'
    Then the disclosed quantity fields should accept the values

  @ui @p1
  Scenario: Quantity Type Regular disables conditional qty1 and conditional qty2 fields
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I select 'Regular' in 'Quantity Type'
    Then 'Conditional qty1' should be disabled
    And 'Conditional qty2' should be disabled
    When I attempt to enter '10' in 'Conditional qty1'
    Then the value should not be accepted

  @ui @critical @p0
  Scenario: Stop Loss order requires Trigger Price and Limit Price to proceed to Preview
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I select 'Stop Loss Order' as 'Bid price Type'
    And I enter '10' in 'Quantity'
    And I leave 'Trigger Price' empty
    And I enter '100.00' in 'Limit Price'
    And I click 'Place Order'
    Then I should remain in the 'Create' phase
    When I enter '101.00' in 'Trigger Price'
    And I leave 'Limit Price' empty
    And I click 'Place Order'
    Then I should remain in the 'Create' phase
    When I enter '101.00' in 'Trigger Price'
    And I enter '100.00' in 'Limit Price'
    And I click 'Place Order'
    Then I should see the 'Preview' phase

  @ui @critical @p0
  Scenario: Market type disables Price and Trigger Price fields
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    When I select 'Market' as the order type
    Then the 'Price' field should be disabled
    And the 'Trigger Price' field should be disabled

  @ui @p1
  Scenario Outline: Validity Type supports options and auto-populates Validity Date
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    And I enter '10' in 'Quantity'
    And I enter '100.00' in 'Price'
    When I select '<validity_type>' in 'Validity Type'
    Then 'Validity Date' should be auto populated

    Examples:
      | validity_type   |
      | Good for the day|
      | At the opening  |
      | Fill or Kill    |

  @ui @p1
  Scenario: Jumbo Flag is reflected on Preview
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    And I select a valid symbol and exchange
    And I enter '10' in 'Quantity'
    And I enter '100.00' in 'Price'
    When I check 'Jumbo Flag'
    And I click 'Place Order'
    Then I should see the 'Preview' phase
    And I should see 'Jumbo' indicator in the order details
    When I click 'Back' or 'Cancel'
    Then I should not reach the 'Confirmation' phase

  @ui @p1
  Scenario: Create screen shows balances (Security Balance, Trade balance, Available balance, Additional limit)
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I open 'Orders' > 'Order Entry'
    Then I should see 'Security Balance'
    And I should see 'Trade balance'
    And I should see 'Available balance'
    And I should see 'Additional limit'

  @ui @critical @p0
  Scenario: Place Order opens Preview showing symbol, quantity/price, jumbo flag and advisory number
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I select a valid symbol and exchange
    And I enter 'ADV-TEST-0001' in 'Advisory Number'
    And I enter '10' in 'Quantity'
    And I enter '100.00' in 'Price'
    And I check 'Jumbo Flag'
    And I click 'Place Order'
    Then I should see the 'Preview' phase
    And I should see order details including symbol, quantity, price, jumbo flag and advisory number

  @ui @p1
  Scenario: Preview provides print commission details link
    Given I am on the 'Preview' phase for an equity order
    When I locate the 'print commission details' link
    Then the 'print commission details' link should be visible
    When I click the 'print commission details' link
    Then the system should initiate printing or show a print preview

  @ui @critical @p0
  Scenario: Confirm buy requires agreement checkbox to reach Confirmation
    Given I am on the 'Preview' phase for an equity order
    When I ensure 'I Agree for Commission & Order' is unchecked
    And I click 'Buy'
    Then I should not see the 'Confirmation' phase
    When I check 'I Agree for Commission & Order'
    And I click 'Buy'
    Then I should see the 'Confirmation' phase
    And I should see an internal order number

  @ui @critical @p0
  Scenario: Confirmation shows internal order number and links to Order Book and Place New Order
    Given I am on the 'Confirmation' screen for an equity order
    When I view the confirmation details
    Then I should see the internal order number
    And I should see a link to 'Order Book'
    And I should see a link to 'Place New Order'
    When I click the 'Order Book' link
    Then I should see the 'Order Book' screen
    When I navigate back and click 'Place New Order'
    Then I should see a new 'Order Entry' context

  @ui @p1
  Scenario: Confirmation allows refreshing order status using refresh symbol adjacent to status
    Given I am on the 'Confirmation' screen for an equity order
    When I locate the refresh symbol adjacent to 'Status'
    Then the refresh symbol should be visible
    When I click the status refresh symbol
    Then the status area should refresh without leaving the confirmation screen

  # -----------------------------
  # UI Tests - Sell Order
  # -----------------------------
  @ui @critical @p0
  Scenario: Sell order entry follows Create -> Preview -> Confirmation similar to buy
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I open 'Orders' > 'Order Entry'
    And I switch transaction side to 'Sell'
    And I select a held security symbol and exchange
    And I enter required sell order details
    And I click 'Place Order'
    Then I should see the 'Preview' phase with sell order summary
    When I check 'I Agree for Commission & Order'
    And I click 'Sell' to confirm
    Then I should see the 'Confirmation' phase
    And I should see an internal order number

  @ui @critical @p0
  Scenario: Full Sell option available and reflected on Preview/Confirmation
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer with holdings and enter Trading
    When I open 'Orders' > 'Order Entry'
    And I switch transaction side to 'Sell'
    And I select a held security symbol and exchange
    And I select 'Full Sell'
    And I click 'Place Order'
    Then I should see the 'Preview' phase
    And the order summary should indicate 'Full Sell' is selected

  @ui @p1
  Scenario: Full Sell with fractional holdings is not supported and does not confirm fractional liquidation
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer with fractional holdings and enter Trading
    When I open 'Orders' > 'Order Entry'
    And I switch transaction side to 'Sell'
    And I select a security with fractional holdings
    And I select 'Full Sell'
    And I click 'Place Order'
    Then the system should block or adjust the flow such that fractional quantity is not successfully confirmed for sale

  # -----------------------------
  # UI Tests - Order Book & Order Trail
  # -----------------------------
  @ui @critical @p0
  Scenario: Equity Order Book filters by Exchange, Instrument, Mode, Order Status, Symbol and Go shows results
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    When I open 'Orders' > 'Order Book' > 'Equity Order Book'
    And I select an 'Exchange'
    And I select an 'Instrument type'
    And I select a 'Mode'
    And I select an 'Order Status'
    And I enter a 'Symbol'
    And I click 'Go'
    Then I should see an equity order list matching the selected criteria

  @ui @p1
  Scenario: Equity Order Book Order Status list includes Modification Transit and Expired
    Given I am on the 'Equity Order Book' screen
    When I open the 'Order Status' dropdown
    Then I should see 'Modification Transit' in the list
    And I should see 'Expired' in the list

  @ui @p2
  Scenario: Equity Order Book pagination uses right arrow and export via excel icon
    Given I am on the 'Equity Order Book' screen with results spanning multiple pages
    When I click the right arrow pagination control
    Then I should see the next page of order book results
    When I click the excel export icon
    Then an excel file download should be initiated

  @ui @p1
  Scenario: Equity Order Book displays required columns including modify/cancel link and call centre id and user id
    Given I am on the 'Equity Order Book' screen with at least one result row
    When I view the grid header and first row
    Then I should see columns including 'exchange', 'symbol', 'company name', 'buy/sell', 'type', 'quantity', 'price', 'status'
    And I should see columns including 'executed qty', 'open quantity', 'validity', 'date and time', 'internal order number', 'instrument'
    And I should see 'call centre id' column
    And I should see 'user id' column

  @ui @p2
  Scenario: Clicking symbol in Equity Order Book opens quotes screen
    Given I am on the 'Equity Order Book' screen with at least one result row
    When I click the 'symbol' value in the first row
    Then I should see the 'Quotes' screen for that symbol
    When I close the quotes screen
    Then I should return to the 'Equity Order Book' screen

  @ui @p1
  Scenario: Clicking internal order number opens equity order trail window
    Given I am on the 'Equity Order Book' screen with at least one result row
    When I click the 'internal order number' value in the first row
    Then I should see the 'Order Trail' window for that order
    And the internal order number in Order Trail should match the clicked value

  @ui @p2
  Scenario: Order Trail provides export to excel, refresh and help controls
    Given I am on the 'Order Trail' window
    When I verify presence of 'Refresh' and 'Help' controls
    Then 'Refresh' should be visible
    And 'Help' should be visible
    When I click 'Export to Excel'
    Then an excel file download should be initiated
    When I click 'Refresh'
    Then the order trail content should reload without error
    When I click 'Help'
    Then help content should be displayed

  # -----------------------------
  # UI Tests - Order Modification & Cancellation
  # -----------------------------
  @ui @critical @p0
  Scenario: Modification is allowed only for Pending orders
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open the 'Equity Order Book' screen
    When I select an order row with status not equal to 'Pending'
    Then the 'Modify' action should be disabled or not available for that order

  @ui @critical @p0
  Scenario: Modify flow transitions Modify Order -> Submit -> Order Verification -> Confirm and receives confirmation
    Given I am on the 'Equity Order Book' screen with a 'Pending' order available
    When I click 'Modify Order' for the pending order
    Then I should see the order details in the order entry form
    When I change the 'Price' to a new valid value
    And I click 'Submit'
    Then I should see the 'Order Verification' screen
    When I click 'Confirm'
    Then I should see an exchange modification confirmation message

  @ui @p1
  Scenario: After exchange modification confirmation, order status becomes Modified
    Given I have successfully confirmed a modification for an order
    When I refresh or re-run the 'Equity Order Book' search
    Then the order status should be 'Modified' for the same internal order number

  @ui @critical @p0
  Scenario: Cancellation is allowed only for Pending orders
    Given I am on the 'Equity Order Book' screen
    When I select an order row with status not equal to 'Pending'
    Then the 'Cancel' action should be disabled or not available for that order

  @ui @critical @p0
  Scenario: Cancel flow sends cancellation request to exchange and receives confirmation message
    Given I am on the 'Equity Order Book' screen with a 'Pending' order available
    When I click 'Cancel Order' for the pending order
    Then I should see a cancellation confirmation dialog
    When I click 'Confirm'
    Then I should see an exchange cancellation confirmation message

  @ui @p2
  Scenario: Cancel dialog Close discontinues cancellation and order remains Pending
    Given I am on the 'Equity Order Book' screen with a 'Pending' order available
    When I click 'Cancel Order' for the pending order
    Then I should see a cancellation confirmation dialog
    When I click 'Close'
    Then the dialog should close
    And the order status should remain 'Pending'

  @ui @p1
  Scenario: After refreshing order book, cancelled order status changes to cancel
    Given I have successfully confirmed cancellation for an order
    When I refresh or re-run the 'Equity Order Book' search
    Then the order status should be 'cancel' for the same internal order number

  # -----------------------------
  # UI Tests - Mutual Fund NAV, Purchase, Redeem & Order Book/Trail
  # -----------------------------
  @ui @p1
  Scenario: NAV List displays required columns
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open the 'NAV List' screen
    Then I should see columns 'AMC Name', 'Scheme Name', 'Symbol', 'Exchange Code', 'Buy NAV', 'Sell NAV'
    And I should see columns 'Currency' and 'NAV as on Date'

  @ui @p1
  Scenario Outline: NAV List supports filtering by AMC Name and by symbol/Exchange code
    Given I am on the 'NAV List' screen with multiple rows
    When I apply filter '<filter_type>' with value '<filter_value>'
    Then the NAV List results should match '<filter_type>' equals '<filter_value>'
    When I clear NAV List filters
    Then I should see the unfiltered NAV List results

    Examples:
      | filter_type          | filter_value |
      | AMC Name             | AMC_A        |
      | Symbol/Exchange Code | SYM_EX_01    |

  @ui @p2
  Scenario: NAV List export using excel icon initiates download
    Given I am on the 'NAV List' screen with at least one row
    When I click the excel export icon
    Then an excel file download should be initiated

  @ui @p2
  Scenario: NAV List Security Details symbol opens selected security details
    Given I am on the 'NAV List' screen with at least one row
    When I click the 'Security Details' symbol for the first row
    Then I should see the 'Security Details' view for that scheme
    When I close the 'Security Details' view
    Then I should return to the 'NAV List' screen

  @ui @p1
  Scenario Outline: NAV List Purchase and Redeem links open respective screens
    Given I log in with valid call centre credentials through SSO
    And I authenticate a customer and enter Trading
    And I open the 'NAV List' screen
    When I click '<action>' link for a scheme row
    Then I should see the 'MF <action>' screen

    Examples:
      | action  |
      | Purchase|
      | Redeem  |

  @ui @critical @p0
  Scenario: MF Purchase create screen opened from NAV List auto-populates fund details
    Given I authenticate a customer and enter Trading
    And I open the 'NAV List' screen
    When I click 'Purchase' for a scheme row
    Then I should see the 'MF Purchase' create screen
    And I should see auto-populated fields including 'Symbol', 'Scheme Name', 'AMC Name', 'Currency', 'Latest NAV', 'NAV as on', 'Cut off Time', 'Unit Face Value'

  @ui @p1
  Scenario: MF Purchase opened directly requires entering symbol to auto-populate details
    Given I authenticate a customer and enter Trading
    When I open the 'MF Purchase' screen directly
    Then the fund details should be empty until a symbol is entered
    When I enter a valid MF symbol in the 'Symbol' field
    Then the fund details should populate automatically

  @ui @critical @p0
  Scenario Outline: MF Purchase supports Units or Amount input and shows balances before placing order
    Given I authenticate a customer and enter Trading
    And I open the 'MF Purchase' create screen for a scheme
    When I view the create screen
    Then I should see 'Trade balance'
    And I should see 'available balance'
    And I should see 'additional limit'
    When I enter '<input_value>' into '<input_field>'
    Then the field '<input_field>' should accept the value
    When I click 'Reset'
    Then '<input_field>' should be cleared

    Examples:
      | input_field | input_value |
      | Units       | 1           |
      | Amount      | 1           |

  @ui @p2
  Scenario: MF Purchase has Fund Policy link
    Given I authenticate a customer and enter Trading
    And I open the 'MF Purchase' create screen for a scheme
    When I locate the 'Fund Policy' link
    Then the 'Fund Policy' link should be visible
    When I click the 'Fund Policy' link
    Then I should see Fund Policy content
    When I close Fund Policy content
    Then I should return to the 'MF Purchase' create screen

  @ui @p1
  Scenario: MF Purchase advised order supports advisory checkbox and advisory reference number
    Given I authenticate a customer and enter Trading
    And I open the 'MF Purchase' create screen for a scheme
    When I check the 'Advisory' checkbox
    Then the 'Advisory reference number' field should be enabled
    When I enter 'ADV-TEST-0001' in 'Advisory reference number'
    Then the advisory reference number should be accepted

  @ui @critical @p0
  Scenario: MF Purchase Place order shows alerts then Proceed -> Preview and Confirm -> Confirmation with status
    Given I authenticate a customer and enter Trading
    And I open the 'MF Purchase' create screen for a scheme
    When I set 'Order date'
    And I enter '1' in 'Units'
    And I click 'Place order'
    Then I should see an alerts list
    When I click 'Proceed'
    Then I should see the 'MF Purchase Preview' screen
    When I click 'Confirm'
    Then I should see the 'MF Purchase Confirmation' screen
    And I should see the order status

  @ui @p2
  Scenario: MF Purchase create screen provides Reset and Close buttons
    Given I authenticate a customer and enter Trading
    And I open the 'MF Purchase' create screen for a scheme
    When I verify 'Reset' and 'Close' buttons are visible
    Then 'Reset' should be visible
    And 'Close' should be visible
    When I enter '1' in 'Units'
    And I click 'Reset'
    Then 'Units' should be cleared
    When I click 'Close'
    Then the MF Purchase screen should close

  @ui @critical @p0
  Scenario: MF Redeem opened from NAV List auto-populates details and direct open requires symbol entry
    Given I authenticate a customer and enter Trading
    And I open the 'NAV List' screen
    When I click 'Redeem' for a scheme row
    Then I should see the 'MF Redeem' create screen
    And I should see auto-populated fields including 'Symbol', 'Scheme Name', 'AMC Name', 'Currency', 'Latest NAV', 'NAV as on', 'Cut off Time', 'Unit Face Value'
    When I close the 'MF Redeem' screen
    And I open the 'MF Redeem' screen directly
    And I enter a valid MF symbol in the 'Symbol' field
    Then the fund details should populate automatically

  @ui @critical @p0
  Scenario: MF Redeem supports Full sell flag
    Given I authenticate a customer with MF holdings and enter Trading
    And I open the 'MF Redeem' create screen for a scheme
    When I check the 'Full sell' flag
    Then the 'Full sell' flag should be selected
    When I click 'Place order'
    Then I should see an alerts list

  @ui @p1
  Scenario: MF Redeem supports Units or Amount and enforces one input method
    Given I authenticate a customer with MF holdings and enter Trading
    And I open the 'MF Redeem' create screen for a scheme
    When I enter '1' in 'Units'
    Then 'Units' should accept the value
    When I clear 'Units'
    And I enter '1.00' in 'Amount'
    Then 'Amount' should accept the value
    When I enter '1' in 'Units'
    And I keep '1.00' in 'Amount'
    Then the screen should enforce a single input method for redemption

  @ui @critical @p0
  Scenario: MF Redeem Place order shows alerts then Proceed -> Preview and Confirm -> Confirmation with Order Book link
    Given I authenticate a customer with MF holdings and enter Trading
    And I open the 'MF Redeem' create screen for a scheme
    When I set 'Order date'
    And I enter '2' in 'Units'
    And I click 'Place order'
    Then I should see an alerts list
    When I click 'Proceed'
    Then I should see the 'MF Redeem Preview' screen
    When I click 'Confirm'
    Then I should see the 'MF Redeem Confirmation' screen
    And I should see the order status
    And I should see an 'Order Book' link
    When I click the 'Order Book' link
    Then I should see the 'MF Order Book' screen

  @ui @p1
  Scenario: MF Order Book shows required fields including Action, Units, NAV, Order Status, Executed Units, Source
    Given I authenticate a customer and enter Trading
    When I open 'Orders' > 'MF Order Book'
    And I click 'Go'
    Then I should see columns 'Exchange', 'Symbol', 'Scheme Name'
    And I should see columns 'Action', 'Units', 'NAV', 'Order Status', 'Executed Units'
    And I should see columns 'Date & Time', 'Internal Order Number', 'Source'

  @ui @p2
  Scenario: MF Order Trail opens from internal order number and supports export to excel
    Given I am on the 'MF Order Book' screen with at least one row
    When I click the 'Internal Order Number' for the first row
    Then I should see the 'MF Order Trail' screen
    When I click the excel icon on the MF Order Trail screen
    Then an excel file download should be initiated

  # -----------------------------
  # UI Tests - ETF
  # -----------------------------
  @ui @p1
  Scenario: ETF List supports entering symbol and selecting from list
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open the 'ETF List' screen
    Then I should see a list of ETF records
    When I search by ETF symbol and apply search
    Then I should see matching ETF results
    When I select an ETF row
    Then I should see row-level options available for that ETF

  @ui @p1
  Scenario: ETF List provides Purchase/Redeem (MF path) and Buy/Sell (Equity path)
    Given I authenticate a customer and enter Trading
    And I open the 'ETF List' screen
    When I click 'Purchase' for an ETF row
    Then I should see the 'Mutual Fund' order entry flow
    When I return to the ETF List and click 'Buy' for an ETF row
    Then I should see the 'Equity Order Entry' flow

  @ui @critical @p0
  Scenario Outline: ETF order from Buy/Sell icon shows popup to select order path and routes accordingly
    Given I log in with valid call centre credentials through SSO
    And I open a screen that shows an ETF row with a Buy/Sell icon
    When I click the ETF Buy/Sell icon
    Then I should see an ETF order popup asking me to select the order placement path
    When I select '<path>' and click 'Proceed'
    Then I should see the '<expected_flow>' order entry flow

    Examples:
      | path        | expected_flow              |
      | Equity      | Equity Order Entry         |
      | Mutual Fund | Mutual Fund Order Entry    |

  # -----------------------------
  # UI Tests - Trade Book & History Reports
  # -----------------------------
  @ui @p1
  Scenario: Trade Book lists current date trades and excludes Mutual Fund trades
    Given I authenticate a customer and enter Trading
    When I open 'Trade Book'
    And I set Exchange, Instrument and Symbol with trades and click 'GO'
    Then I should see trades executed on the current date
    And I should not see Mutual Fund trades in the Trade Book list

  @ui @p1
  Scenario Outline: Trade Book search requires Exchange, Instrument and Symbol then GO
    Given I authenticate a customer and enter Trading
    When I open 'Trade Book'
    And I select '<instrument>' in 'Instrument'
    And I select an Exchange
    And I enter a Symbol
    And I click 'GO'
    Then I should see Trade Book results matching the criteria

    Examples:
      | instrument |
      | equity     |
      | bond       |
      | T-bill     |

  @ui @p2
  Scenario: Trade Book supports export to excel
    Given I authenticate a customer and enter Trading
    And I open 'Trade Book'
    When I run a search that returns at least one trade row
    And I click the excel export control
    Then an excel file download should be initiated

  @ui @p1
  Scenario: Order History accessed under Reports -> History reports -> order history with exchange/instrument/date range
    Given I authenticate a customer and enter Trading
    When I open 'Reports' > 'History reports'
    And I select the 'order history' tab
    And I select an Exchange
    And I select an Instrument
    And I select a date range using the calendar icon
    And I click 'Go'
    Then I should see Order History results

  @ui @p2
  Scenario: Order History supports excel export
    Given I authenticate a customer and enter Trading
    And I open 'Reports' > 'History reports' > 'order history'
    When I run a report that returns results
    And I click the excel export option
    Then an excel file download should be initiated

  @ui @p1
  Scenario: Trade History accessed under Reports -> History reports -> trade history with calendar date range
    Given I authenticate a customer and enter Trading
    When I open 'Reports' > 'History reports'
    And I select the 'trade history' tab
    And I select a date range using the calendar icon
    And I click 'Go'
    Then I should see Trade History results
    And the results dates should fall within the selected range

  @ui @p2
  Scenario: Trade History supports excel export
    Given I authenticate a customer and enter Trading
    And I open 'Reports' > 'History reports' > 'trade history'
    When I run a report that returns results
    And I click the excel export option
    Then an excel file download should be initiated

  # -----------------------------
  # UI Tests - Advanced Search
  # -----------------------------
  @ui @p2
  Scenario Outline: Advanced Search link beside Symbol supports criteria and returns security on Go
    Given I authenticate a customer and enter Trading
    And I open 'Orders' > 'Order Entry'
    When I click the 'Advanced Search' link beside the Symbol search
    Then I should see the 'Advance Search' screen
    And I should see criteria options including 'ISIN', 'TICKER', 'Instrument Id', 'Exchange Code'
    When I select '<criteria>' as criteria
    And I enter '<search_code>' in 'Search Code'
    And I click 'Go'
    Then I should see at least one returned security result
    When I select the returned security
    Then the selected security should be populated back in the order entry context

    Examples:
      | criteria      | search_code   |
      | ISIN          | TESTISIN0001  |
      | TICKER        | TSTICK1       |
      | Instrument Id | INST123       |
      | Exchange Code | EXC01         |

  # -----------------------------
  # UI Tests - Makam Calculator
  # -----------------------------
  @ui @p1
  Scenario Outline: Makam Calculator requires mandatory fields before Submit produces outputs
    Given I authenticate a customer and enter Trading
    And I open the 'Makam Calculator' screen
    When I set 'Makam price' to '<makam_price>'
    And I set 'Days to redemption' to '<days>'
    And I set 'Tax rate' to '<tax>'
    And I click 'Submit'
    Then the yield outputs '<output_state>' be displayed

    Examples:
      | makam_price | days | tax | output_state |
      |             | 30   | 15  | should not   |
      | 100         |      | 15  | should not   |
      | 100         | 30   |     | should not   |
      | 100         | 30   | 15  | should       |

  @ui @p2
  Scenario Outline: Makam Calculator accepts optional fees as zero or blank and still computes outputs
    Given I authenticate a customer and enter Trading
    And I open the 'Makam Calculator' screen
    When I enter 'Makam price' as '95'
    And I enter 'Days to redemption' as '120'
    And I enter 'Tax rate' as '15'
    And I set 'Buy fee' to '<buy_fee>'
    And I set 'Sell fee' to '<sell_fee>'
    And I set 'Custodian fee' to '<custodian_fee>'
    And I click 'Submit'
    Then the yield outputs should be displayed

    Examples:
      | buy_fee | sell_fee | custodian_fee |
      | 0       | 0        | 0             |
      |         |          |               |

  @ui @p2
  Scenario: Makam Calculator Submit displays all yield outputs
    Given I authenticate a customer and enter Trading
    And I open the 'Makam Calculator' screen
    When I enter mandatory fields and optional fees
    And I click 'Submit'
    Then I should see 'Effective yield (before tax)'
    And I should see 'Effective yield (after tax)'
    And I should see 'Nominal yield (before tax)'
    And I should see 'Nominal yield (after tax)'
    And I should see 'Effective yield (before tax and fees)'
    And I should see 'Effective yield (after tax and fees)'
    And I should see 'Nominal yield (before tax and fees)'
    And I should see 'Nominal yield (after tax and fees)'

  # -----------------------------
  # UI Tests - Tax Simulation
  # -----------------------------
  @ui @critical @p0
  Scenario: Tax Simulation first screen lists securities and shows required columns
    Given I authenticate a customer and enter Trading
    When I open the 'Tax Simulation' module
    Then I should see a securities list
    And I should see columns 'Symbol', 'Security Name', 'Quantity Previous EOD', 'LTP', 'Currency'

  @ui @critical @p0
  Scenario: Tax Simulation quantity must be less than or equal to available quantity and price is editable
    Given I authenticate a customer and enter Trading
    And I open the 'Tax Simulation' module
    When I select a security row with available quantity shown
    And I set 'Quantity' equal to the available quantity
    And I set 'Selling Price' to a valid value
    And I click 'Simulate'
    Then I should see the tax simulation result screen
    When I go back to the selection screen
    And I set 'Quantity' greater than the available quantity
    And I click 'Simulate'
    Then I should remain on the selection screen or see a validation preventing results display

  @ui @p1
  Scenario: Tax Simulation result screen provides Option To Sell with mentioned price and quantity
    Given I authenticate a customer and enter Trading
    And I open the 'Tax Simulation' module
    When I select a security and set a valid quantity and selling price
    And I click 'Simulate'
    Then I should see an 'Option To Sell' for the simulated security
    And the option should correspond to the mentioned price and quantity shown in the results

  # -----------------------------
  # UI Tests - Fund Balance & Blocked Cash
  # -----------------------------
  @ui @critical @p0
  Scenario: Fund Balance requires selecting Account and Currency then Go and shows balances in both currencies
    Given I authenticate a customer and enter Trading
    When I open 'Account & Portfolio' > 'Fund Balance'
    And I select an Account from the dropdown
    And I select a Currency from the dropdown
    And I click 'Go'
    Then I should see fund balance details
    And fund balance details should be shown in the account currency and the selected currency

  @ui @p1
  Scenario: Fund Balance displays required fields and supports example arithmetic verification when seeded
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Fund Balance'
    When I select the seeded test Account and Currency 'ILS'
    And I click 'Go'
    Then I should see fields 'Net Balance', 'Trade Balance', 'Blocked Balance', 'Available fund', 'Free balance', 'OD Limit'
    And the displayed balances should match seeded example calculations

  @ui @critical @p1
  Scenario: Blocked cash details drilldown shows required fields
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Fund Balance'
    When I select an account row
    And I click 'Blocked cash details'
    Then I should see the 'Cash Block Drill Down' screen
    And I should see fields 'Blocked amount', 'blocked currency', 'transaction type', 'blocked reference number', 'block date', 'block release date'

  # -----------------------------
  # UI Tests - Portfolio Valuation & Detailed Portfolio Valuation
  # -----------------------------
  @ui @critical @p0
  Scenario: Portfolio Valuation defaults to Today and supports Historical by changing date
    Given I authenticate a customer and enter Trading
    When I open 'Account & Portfolio' > 'Portfolio Valuation'
    Then the valuation date context should default to 'Today'
    When I change the valuation date to a prior business date and apply
    Then I should see the valuation list update for the selected historical date
    When I change the valuation date back to 'Today' and apply
    Then I should see the valuation list for today again

  @ui @p2
  Scenario: Portfolio Valuation provides Exchange rate link
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Portfolio Valuation'
    When I click the 'Exchange rate' link
    Then I should see an exchange rates view
    When I close the exchange rates view
    Then I should return to 'Portfolio Valuation'

  @ui @p2
  Scenario: Portfolio Valuation displays securities in base currency ILS/USD
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Portfolio Valuation'
    When I locate an ILS-base security row
    Then the currency for that row should be 'ILS'
    When I locate a USD-base security row
    Then the currency for that row should be 'USD'

  @ui @p2
  Scenario: Portfolio Valuation supports export to excel sheet
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Portfolio Valuation'
    When I click 'Export to Excel'
    Then an excel file download should be initiated

  @ui @p1
  Scenario: Detailed Portfolio Valuation accessible under Day valuation and supports Exchange wise and Asset wise
    Given I authenticate a customer and enter Trading
    When I open 'Account & Portfolio' > 'Day valuation'
    Then I should see the 'Detailed Portfolio Valuation' screen
    When I switch to 'Exchange wise' view
    Then securities should be grouped by exchange
    When I switch to 'Asset wise' view
    Then securities should be grouped by asset class

  @ui @p2
  Scenario: Detailed Portfolio Valuation grouping is based on Currency irrespective of view
    Given I am on the 'Detailed Portfolio Valuation' screen
    When I view the holdings list
    Then I should see holdings grouped by currency
    When I switch between 'Exchange wise' and 'Asset wise'
    Then holdings should remain grouped by currency

  @ui @p2
  Scenario: Selecting a security shows news and chart (intra-day and across days)
    Given I am on the 'Detailed Portfolio Valuation' screen
    When I select a security row
    Then I should see news for the selected security
    And I should see an intra-day chart for the selected security
    When I switch the chart to an across-days view
    Then I should see a multi-day chart for the selected security

  @ui @p1
  Scenario: Detailed Portfolio Valuation allows Buy/Sell from portfolio list
    Given I am on the 'Detailed Portfolio Valuation' screen
    When I click 'Buy' for a security row
    Then I should see the order entry flow for that security
    When I close the order entry flow
    And I click 'Sell' for a security row
    Then I should see the order entry flow for that security

  @ui @p1
  Scenario: Corporate Action link displayed for pending corporate action on a security
    Given I am on the 'Detailed Portfolio Valuation' screen with a security having pending corporate action
    When I locate the security row
    Then I should see a 'Corporate Action' link for that security
    When I click the 'Corporate Action' link
    Then I should see the corporate action view for that security

  @ui @p2
  Scenario: Expanding a security row using plus sign shows required security-wise details fields
    Given I am on the 'Detailed Portfolio Valuation' screen
    When I click the '+' expand control for a security row
    Then I should see details including 'Company name', 'Symbol', 'Last price', 'Change'
    And I should see 'Available quantity' and 'Blocked quantity'
    And I should see 'Cost price', 'Cost Value', 'Market Value'
    And I should see 'Day gain/loss (%)', 'Unrealized Gain/Loss (%)', 'Total quantity'

  @ui @p2
  Scenario: Portfolio list icons C/A/U/P are shown for seeded conditions
    Given I am on the 'Detailed Portfolio Valuation' screen with seeded icon conditions
    When I view the holdings list
    Then I should see icon 'C' for a security with pending corporate action
    And I should see icon 'A' for an American security
    And I should see icon 'U' for a security with uncleared trades
    And I should see icon 'P' for a pledged position

  @ui @p2
  Scenario: Block Details shows block date and movement description
    Given I am on the 'Detailed Portfolio Valuation' screen
    And I select a security with blocked quantity
    When I click 'Block Details'
    Then I should see block details including 'block date' and 'movement description'

  @ui @p2
  Scenario: Security Transaction shows breakdown of security buy/sell activity
    Given I am on the 'Detailed Portfolio Valuation' screen
    When I click 'Security Transaction' for a security
    Then I should see a transaction breakdown including buy and sell activity for the selected security

  # -----------------------------
  # UI Tests - Portfolio Summary
  # -----------------------------
  @ui @p1
  Scenario: Portfolio Summary shows Overall Summary, Heat map, and Fund Balances & Break-up sections
    Given I authenticate a customer and enter Trading
    When I open 'Account & Portfolio' > 'Portfolio Summary'
    Then I should see 'Overall Summary' section
    And I should see 'Heat map' section
    And I should see 'Fund Balances & Break-up' section
    And the break-up section should include criteria based on sector, exchange and currency

  @ui @p2
  Scenario Outline: Portfolio Summary pie chart supports criteria and shows valuation data below chart
    Given I am on the 'Portfolio Summary' screen
    When I select pie criteria '<criteria>'
    Then the pie chart should update to '<criteria>' composition
    And I should see valuation data labels 'Net Balance', 'Market Value', 'Cost Value', 'Overall Gain/Loss'

    Examples:
      | criteria |
      | Sector   |
      | Symbol   |
      | Currency |
      | Exchange |

  # -----------------------------
  # UI Tests - Market Watch, Charts, Get Quote, Index Watch, News
  # -----------------------------
  @ui @p1
  Scenario: Create new market watch and open saved market watch
    Given I log in with valid call centre credentials through SSO
    When I open 'Market View' > 'Market Watch' > 'New Market Watch'
    Then I should see a new Market Watch instance
    When I open 'Market View' > 'Market Watch' > 'Open Market Watch'
    Then I should see the saved Market Watch selection
    When I select saved Market Watch 'MW_SAVED_TEST_01'
    Then I should see Market Watch 'MW_SAVED_TEST_01'

  @ui @p2
  Scenario: Market Watch Add/Edit security adds one security at a time and supports replacement
    Given I am on a Market Watch screen with edit permissions
    When I right click on the market watch and select 'Add/Edit security'
    And I add security 'SEC_A'
    Then I should see security 'SEC_A' in the market watch list
    When I right click on 'SEC_A' and select 'Add/Edit security' to replace with 'SEC_B'
    Then I should not see security 'SEC_A' in the replaced row
    And I should see security 'SEC_B' in that row

  @ui @p2
  Scenario: Market Watch Add Multiple Security adds multiple securities in one go
    Given I am on a Market Watch screen with edit permissions
    When I right click on the market watch and select 'Add Multiple Security'
    And I select securities 'SEC_1', 'SEC_2', 'SEC_3' and confirm
    Then I should see security 'SEC_1' in the market watch list
    And I should see security 'SEC_2' in the market watch list
    And I should see security 'SEC_3' in the market watch list

  @ui @p2
  Scenario: Market Watch supports Delete Security, Rename, Save, and Customize via right click
    Given I am on a Market Watch screen with edit permissions and at least one security present
    When I right click and select 'Customize Market Watch'
    Then I should see the market watch customization UI
    When I close the customization UI
    And I right click and select 'Rename Market Watch'
    And I rename it to 'MW_ACTIONS_TEST_01_RENAMED'
    Then the market watch name should display 'MW_ACTIONS_TEST_01_RENAMED'
    When I right click and select 'Save Market Watch'
    Then the market watch should be saved without error
    When I select a security row and right click and select 'Delete Security'
    Then the selected security row should be removed from the market watch

  @ui @critical @p0
  Scenario: Place order from Market Watch defaults required attributes into order entry
    Given I authenticate a customer and enter Trading
    And I open a Market Watch that contains symbol 'SEC_ORD' with exchange 'TASE'
    When I select the 'SEC_ORD' row
    And I invoke the order entry panel from the market watch
    Then I should see the order entry screen
    And the order entry 'Symbol' should be pre-populated with 'SEC_ORD'
    And the order entry 'Exchange' should be pre-populated with 'TASE'
    When I close the order entry screen without placing the order
    Then I should return to the Market Watch screen

  @ui @p2
  Scenario: Market by Price invoked from Market Watch defaults security and exchange and shows MBP details
    Given I log in with valid call centre credentials through SSO
    And I open Market Watch 'MW_MBP_TEST_01'
    When I select the 'SEC_MBP' row
    And I invoke 'Market by Price'
    Then I should see the 'Market by Price' screen
    And the security id should be defaulted to 'SEC_MBP'
    And the exchange id should be defaulted from the market watch selection
    And MBP details should be displayed

  @ui @p1
  Scenario: Top Gainers/Losers supports criteria and cutoff upper limit filtering
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Market View' > 'Top Gainers/Losers'
    And I select an Exchange
    And I select a Criteria
    And I enter cutoff value '1.50'
    And I click 'Go'
    Then each displayed row value for the selected criteria should be less than or equal to '1.50'
    When I change cutoff value to '1.49' and click 'Go'
    Then each displayed row value for the selected criteria should be less than or equal to '1.49'

  @ui @p2
  Scenario: Chart View opens new window and offers Basic and interactive charts
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    And I open 'Market View' > 'Market Watch'
    When I click the chart option for a security
    Then a new 'Chart View' window should open
    And I should see 'Basic' chart option
    And I should see 'interactive' chart option

  @ui @p2
  Scenario: Chart View supports saving chart as jpeg and png
    Given I have the 'Chart View' window open
    When I save the chart as 'jpeg'
    Then a 'jpeg' image download should be initiated
    When I save the chart as 'png'
    Then a 'png' image download should be initiated

  @ui @p2
  Scenario: Interactive chart supports hover OHLC and From/To date range
    Given I have the 'Chart View' window open
    When I select 'interactive' chart option
    Then I should see interactive chart controls
    When I hover over the chart line at a point
    Then I should see values including open, high, low, close for that time point
    When I set 'From Date' and 'To Date' for a range
    Then the chart should update to show data for the selected date range

  @ui @p2
  Scenario: Interactive chart provides pen option to draw lines/marks
    Given I have the 'Chart View' window open
    When I select 'interactive' chart option
    And I select the 'pen' option
    And I draw a line on the chart
    Then the drawn line should be visible on the chart

  @ui @p1
  Scenario: Get Quote displays market depth up to top 5 buyers and sellers
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Get Quote' for a security
    Then I should see market depth with at most 5 bid levels
    And I should see market depth with at most 5 offer levels

  @ui @p1
  Scenario: Get Quote screen provides required links and they are clickable
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    And I open 'Get Quote' for a security
    When I verify link 'Add to quickie' is visible
    Then 'Add to quickie' should be visible
    When I verify link 'Order book' is visible
    Then 'Order book' should be visible
    When I verify link 'Charts' is visible
    Then 'Charts' should be visible
    When I verify link 'Buy and Sell' is visible
    Then 'Buy and Sell' should be visible
    When I verify link 'Corporate action' is visible
    Then 'Corporate action' should be visible
    When I verify link 'Help' is visible
    Then 'Help' should be visible
    When I verify 'Refresh' control is visible
    Then 'Refresh' should be visible

  @ui @p2
  Scenario: Get Quote shows security status/phase/exchange status and refresh reloads quotes
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    And I open 'Get Quote' for a security
    When I view the status area
    Then I should see 'Security Status'
    And I should see 'Phase of security'
    And I should see 'Exchange status'
    When I click 'Refresh' on Get Quote
    Then the quote values should reload or re-render

  @ui @p2
  Scenario: Index Watch requires selecting exchange and displays required index fields
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Market View' > 'Index Watch'
    And I select an Exchange
    Then I should see an indices list in a spreadsheet
    And I should see fields including 'Change', '% Change', '52 Week High', '52 Week low', 'Date', 'Time'

  @ui @p2
  Scenario: Index Watch supports Refresh and Close
    Given I am on the 'Index Watch' screen
    When I click 'Refresh'
    Then the indices information should reload
    When I click 'Close'
    Then the 'Index Watch' screen should close

  @ui @p2
  Scenario: Exchange News supports exchange selection and opening news via headline link
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Research & News' > 'Exchange News'
    And I select an exchange from the dropdown
    Then I should see exchange-specific headlines with date and time
    When I click the headline link
    Then I should see the complete news content

  @ui @p2
  Scenario: Company News requires entering symbol and Go to display detailed news
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Research & News' > 'Company News'
    And I click 'Go' with empty symbol
    Then I should not see updated company detailed news
    When I enter 'TESTSYM' in the company symbol field
    And I click 'Go'
    Then I should see company-specific detailed news for 'TESTSYM'

  # -----------------------------
  # UI Tests - Injob Activities
  # -----------------------------
  @ui @p1
  Scenario: In-job activities do not require customer login
    Given I log in with valid call centre credentials through SSO
    And I do not authenticate a customer
    When I open 'Injob Activities'
    Then I should see the Injob Activities area
    When I run an Injob search using available filters and click 'GO'
    Then I should see results without being forced to authenticate a customer

  @ui @p1
  Scenario: In-job Order Book supports filters and HO can view ALL call centres
    Given I log in as a 'Head Office' user through SSO
    And I do not authenticate a customer
    When I open 'Injob Activities' > 'Injob Order Book'
    Then I should see filters including 'Exchange', 'Instrument', 'Symbol', 'Call Centre Id', and a date range
    When I select a specific call centre id and click 'GO'
    Then results should show rows only for that call centre id
    When I select 'All' for call centre id and click 'GO'
    Then results should include rows from multiple call centre ids

  @ui @p2
  Scenario: In-job Security Holding displays required fields
    Given I log in with valid call centre credentials through SSO
    And I do not authenticate a customer
    When I open 'Injob Activities' > 'Security Holding'
    And I select Exchange, Instrument and Symbol
    And I click 'Go'
    Then I should see fields including 'Account number', 'Name of Client', 'Phone no.', 'Date of Last Trade', 'Amount', 'Profit/Loss'

  @ui @p2
  Scenario: In-job MF Order History supports filters and HO can view ALL call centres
    Given I log in as a 'Head Office' user through SSO
    And I do not authenticate a customer
    When I open 'Injob Activities' > 'Mutual Fund Order History'
    Then I should see filters including 'Symbol', 'Customer', 'Call Centre Id', and a date range
    When I select a specific call centre id and click 'GO'
    Then results should show rows only for that call centre id
    When I select 'All' for call centre id and click 'GO'
    Then results should include rows from multiple call centre ids

  # -----------------------------
  # UI Tests - Corporate Action (from Portfolio Valuation)
  # -----------------------------
  @ui @critical @p0
  Scenario: Corporate Action accessible via CA icon from Portfolio Valuation
    Given I authenticate a customer and enter Trading
    And I open 'Account & Portfolio' > 'Portfolio Valuation'
    When I click the 'CA' icon for a security that has corporate actions
    Then I should see the 'Corporate Action' view for that security

  @ui @critical @p0
  Scenario: Corporate Action displays multiple events and supports Choose Option on behalf of customer
    Given I have the 'Corporate Action' view open for a security with multiple events
    When I view the corporate action events list
    Then I should see multiple CA events displayed one below the other
    When I click 'Choose Option' for the first event
    Then I should see an option selection flow for that event on behalf of the customer

  @ui @p1
  Scenario: Corporate Action View Response allows modify/cancel previously submitted responses
    Given I have the 'Corporate Action' view open for a security with a previously submitted response
    When I open 'View Response'
    Then I should see previously submitted response entries
    When I click 'Modify' for a response
    Then I should see the response modification flow
    When I return to 'View Response' and click 'Cancel' for a response
    Then the response should show a cancelled state after refresh

  # -----------------------------
  # UI Tests - Security Transfer (Transfers)
  # -----------------------------
  @ui @critical @p0
  Scenario: Security Transfer initiation blocks when management unit mismatches with exact error message
    Given I log in as a user whose management unit differs from the customer's management unit
    And I authenticate the customer for the mismatched management unit
    When I click 'Transfers' > 'Security Transfer'
    Then I should see error message 'Kindly visit your home branch to transfer Security'
    And I should not be able to proceed to the 'Add Security' screen

  @ui @critical @p0
  Scenario: Add Security screen shows required fields and transfer quantity defaults to available and is editable
    Given I authenticate a customer and enter Trading
    When I open 'Transfers' > 'Security Transfer'
    Then I should see an Add Security grid with columns 'Exchange', 'Symbol', 'Company Name', 'Instrument Type', 'Available Quantity', 'Currency', 'Previous closing Price', 'Transfer Quantity', 'Value'
    When I compare 'Transfer Quantity' to 'Available Quantity' for a row
    Then 'Transfer Quantity' should equal 'Available Quantity' by default
    When I edit 'Transfer Quantity' to a smaller valid number
    Then the edited 'Transfer Quantity' should be retained

  @ui @critical @p0
  Scenario: Only settled positions are shown; blocked/unsettled positions are not shown
    Given I authenticate a customer with settled, blocked and unsettled positions and enter Trading
    When I open 'Transfers' > 'Security Transfer'
    Then I should see settled positions in the list
    And I should not see blocked positions in the list
    And I should not see unsettled positions in the list

  @ui @critical @p0
  Scenario Outline: Transfer quantity supports fractional quantities for within bank and outside bank
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    When I enter fractional Transfer Quantity '<fraction>' for a selected security
    And I click 'Proceed'
    And I select '<transfer_type>' on Add Beneficiary
    Then the fractional quantity '<fraction>' should be preserved in the transfer flow
    When I click 'Cancel' or 'Back'
    Then the transfer flow should close without release

    Examples:
      | fraction | transfer_type |
      | 1.5      | Within Bank   |
      | 0.1      | Outside Bank  |

  @ui @p1
  Scenario: Selecting CA-pending security shows CA indicator and alert message template
    Given I authenticate a customer with a CA-pending security and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    When I locate the CA-pending security row
    Then I should see a CA indicator in that row
    When I attempt to proceed with the CA-pending security selected
    Then I should see an alert message 'Please note that a corporate action is pending for <<Symbol>>.'

  @ui @critical @p0
  Scenario: Transfer Quantity cannot exceed Available Quantity and shows exact error message template
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    When I set Transfer Quantity greater than Available Quantity for symbol 'TESTSYM'
    And I attempt to proceed
    Then I should see error message 'Transfer Quantity (<<Qty>>) entered for <<Symbol>> is greater than Available Quantity (<<Qty>>). Kindly change'

  @ui @p1
  Scenario: Default exchange dropdown value is TASE on Add Security
    Given I authenticate a customer and enter Trading
    When I open 'Transfers' > 'Security Transfer'
    Then the 'Exchange' dropdown default value should be 'TASE'

  @ui @p1
  Scenario: All checkboxes selected by default and Transfer Quantity equals Available Quantity
    Given I authenticate a customer and enter Trading
    When I open 'Transfers' > 'Security Transfer'
    Then all security row checkboxes should be selected by default
    And each row's 'Transfer Quantity' should equal 'Available Quantity' by default

  @ui @p1
  Scenario: Unchecking a security clears its transfer quantity and rechecking restores default
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    When I set a specific Transfer Quantity for the first row
    And I uncheck the first row checkbox
    Then the first row Transfer Quantity should be cleared
    When I recheck the first row checkbox
    Then the first row Transfer Quantity should default back to Available Quantity

  @ui @p1
  Scenario: Order date defaults to current date and cannot be modified
    Given I authenticate a customer and enter Trading
    When I open 'Transfers' > 'Security Transfer'
    Then the 'Order date' should be today's date
    When I attempt to edit 'Order date'
    Then the 'Order date' should remain unchanged and non-editable

  @ui @critical @p0
  Scenario: Add Beneficiary Transfer from Account Number is defaulted and not editable
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select at least one security and click 'Proceed'
    When I view 'Transfer from Account Number'
    Then it should be populated with the serviced account number
    And it should not be editable

  @ui @critical @p0
  Scenario: Outside Bank option disabled when exchange selected is not TASE
    Given I authenticate a customer with a non-TASE position and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    When I select a non-TASE security and click 'Proceed'
    Then 'Outside Bank' option should be disabled
    When I attempt to select 'Outside Bank'
    Then the selection should not change

  @ui @p1
  Scenario: Virtual Sell enabled only for Within Bank and defaults beneficiary account to source and disables it
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Within Bank'
    Then 'Virtual Sell' should be enabled
    When I check 'Virtual Sell'
    Then the beneficiary account number should default to the source account number
    And the beneficiary account number field should be disabled
    When I select 'Outside Bank'
    Then 'Virtual Sell' should be disabled

  @ui @p1
  Scenario: Within Bank disables Bank/Branch fields and only beneficiary account number is entered
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a security and click 'Proceed'
    When I select 'Within Bank'
    Then 'Bank Code/Name' should be disabled
    And 'Branch Code/Name' should be disabled
    When I enter a beneficiary 'Account Number'
    Then the beneficiary account number should be accepted

  @ui @p1
  Scenario: Outside Bank entering Bank Code and tab displays bank name beside code
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Outside Bank'
    And I enter '1245' in 'Bank Code'
    And I press the 'TAB' key
    Then I should see the bank name displayed beside the bank code

  @ui @p2
  Scenario: Outside Bank magnifier opens list of banks and selection populates bank code and name
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Outside Bank'
    And I click the magnifier next to 'Bank Code'
    Then I should see the 'List of Banks' popup
    When I click a bank code in the list
    Then the selected bank code should populate in 'Bank Code'
    And the bank name should display beside it

  @ui @p2
  Scenario: Outside Bank branch magnifier opens list of branches for selected bank and selection populates branch code and name
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    And I select 'Outside Bank'
    And I select a bank from the list of banks
    When I click the magnifier next to 'Branch Code'
    Then I should see the 'List of Branches' popup for the selected bank
    When I click a branch code in the list
    Then the selected branch code should populate in 'Branch Code'
    And the branch name should display beside it

  @ui @critical @p0
  Scenario: Same Entity auto-determined for within bank matching BP IDs and Transfer Case not populated
    Given I authenticate a customer with a same-entity target account and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Within Bank'
    And I enter the beneficiary account number that matches BP ID with source
    Then the system should determine 'Same Entity'
    And 'Transfer Case' should not be populated

  @ui @critical @p0
  Scenario: When Same Entity not matched, user must select Transfer Case
    Given I authenticate a customer with a different-entity target account and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Within Bank'
    And I enter the beneficiary account number that does not match BP ID with source
    Then 'Same Entity' should not be selected
    When I attempt to proceed without selecting 'Transfer Case'
    Then I should see a validation requiring 'Transfer Case'
    When I select a 'Transfer Case' from the dropdown
    Then the 'Transfer Case' should display the selected value

  @ui @p1
  Scenario: Outside bank Same Entity unticked by default and user can tick or select transfer case
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I select 'Outside Bank'
    Then 'Same Entity' should be unchecked by default
    When I check 'Same Entity'
    Then 'Same Entity' should be checked
    When I uncheck 'Same Entity'
    And I select a 'Transfer Case' from the dropdown
    Then the 'Transfer Case' should display the selected value

  @ui @p1
  Scenario: Transfer Case dropdown enabled only when Same Entity unchecked and disabled when checked
    Given I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a TASE security and click 'Proceed'
    When I ensure 'Same Entity' is unchecked
    Then the 'Transfer Case' dropdown should be enabled
    When I check 'Same Entity'
    Then the 'Transfer Case' dropdown should be disabled
    When I uncheck 'Same Entity'
    Then the 'Transfer Case' dropdown should be enabled

  @ui @critical @p0
  Scenario: Transfer without Identification (Tax Event) option visible only to Head Office
    Given I log in as a 'Non-Head Office' user through SSO
    And I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer' and proceed to 'Add Beneficiary'
    When I open the 'Transfer Case' dropdown
    Then I should not see 'Transfer without Identification (Tax Event)'
    When I log out
    And I log in as a 'Head Office' user through SSO
    And I authenticate the same customer and proceed to 'Add Beneficiary'
    And I open the 'Transfer Case' dropdown
    Then I should see 'Transfer without Identification (Tax Event)'

  @ui @critical @p0
  Scenario: Mutual funds cannot be transferred to other entities when Same Entity not selected
    Given I authenticate a customer with a mutual fund position and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select a mutual fund security and click 'Proceed'
    When I ensure 'Same Entity' is unchecked
    And I attempt to proceed with a different-entity transfer
    Then I should see error message 'Mutual funds cannot be transferred to other entities'

  @ui @p1
  Scenario: Selecting Transfer without Identification (Tax Event) shows informational taxation message
    Given I log in as a 'Head Office' user through SSO
    And I authenticate a customer and enter Trading
    And I open 'Transfers' > 'Security Transfer' and proceed to 'Add Beneficiary'
    When I select 'Transfer without Identification (Tax Event)' in 'Transfer Case'
    Then I should see information message 'Transfer will be taxed and the receiving account will receive the securities at zero cost as Transfer Case selected is no relationship.'

  @ui @critical @p0
  Scenario: Outside bank transfer for non-TASE shows error 'Only TASE securities can be transferred Outside Bank.'
    Given I authenticate a customer with a non-TASE security and enter Trading
    And I open 'Transfers' > 'Security Transfer'
    And I select the non-TASE security and click 'Proceed'
    When I attempt to select 'Outside Bank'
    Then I should see error message 'Only TASE securities can be transferred Outside Bank.'

  @ui @critical @p0
  Scenario: Security Transfer commission computed only after Verify clicked on Preview
    Given I authenticate a customer and enter Trading
    And I start a Security Transfer and reach the 'Preview' screen
    When I view the commission area before clicking 'Verify'
    Then the commission should not be computed yet
    When I click 'Verify' on Preview
    Then commission details should be displayed

  @ui @critical @p0
  Scenario: Preview supports Print Commission Details and View comments and agreement checkbox is present
    Given I am on the 'Security Transfer Preview' screen
    When I click 'Print Commission Details'
    Then the system should initiate printing or show print preview
    When I click 'View comments'
    Then I should see commission comments content
    When I close the comments content
    Then I should return to the 'Security Transfer Preview' screen
    When I locate 'I Agree for Commission & Transfer'
    Then the agreement checkbox should be visible and selectable

  @ui @critical @p0
  Scenario: Release sends Security Transfer request to Back Office and shows Confirmation
    Given I am on the 'Security Transfer Preview' screen
    And I have computed commission by clicking 'Verify'
    And I have checked 'I Agree for Commission & Transfer'
    When I click 'Release'
    Then I should see the 'Security Transfer Confirmation' screen

  # -----------------------------
  # UI Tests - Authorization (Queues, E-Journal, Maker/Checker)
  # -----------------------------
  @ui @p1
  Scenario: Authorization Queue shows My Queue and Pool Queue with definitions
    Given I log in with a user who has access to Authorization Queue through SSO
    When I open 'Authorization Queue'
    Then I should see 'My Queue' and 'Pool Queue' sections
    And I should see definition text for My Queue: 'My Queue: The requests that are assigned to the user upon which action is pending to be taken by the user'
    And I should see definition text for Pool Queue: 'Pool Queue: The requests that are not assigned to anybody an are pending for action to be taken by any of the authorised user'

  @ui @p2
  Scenario: E-Journal shows Initiated By Me and Authorized By Me lists
    Given I log in with a user who has access to E-Journal through SSO
    When I open 'E-Journal'
    Then I should see 'Initiated By Me'
    And I should see 'Authorized By Me'
    When I open 'Initiated By Me'
    Then I should see a list of requests initiated by me
    When I open 'Authorized By Me'
    Then I should see a list of requests authorized by me

  # -----------------------------
  # UI Tests - TASE Self-Transaction
  # -----------------------------
  @ui @critical @p0
  Scenario Outline: Self-Transaction block shows exact error message text
    Given I authenticate a customer with an open TASE order for today and enter Trading
    And the selected TASE security phase is 'Continuous'
    When I attempt to place an opposite order that would result in a self-transaction using '<order_type>' and '<price_relation>'
    Then I should see error message 'Self-Transactions are not allowed in TASE'
    And I should remain on the 'Create' phase

    Examples:
      | order_type | price_relation            |
      | MKT        | crosses open opposite     |
      | LIMIT      | price equal to opposite   |
      | LIMIT      | price greater than opposite |

  @ui @p1
  Scenario: Self-Transaction handling applies on BP level not portfolio level
    Given a BP has two portfolios and an open TASE order exists in portfolio A
    When I authenticate the same BP and select portfolio B and attempt the opposite order on the same security and day
    Then I should see error message 'Self-Transactions are not allowed in TASE'

  # -----------------------------
  # UI Tests - Market Data Subscription rule visibility (where UI indicates delayed/live)
  # -----------------------------
  @ui @critical @p0
  Scenario: Gainer Loser is always delayed for local and foreign contexts
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Market View' > 'Top Gainers/Losers' for a local exchange and click 'Go'
    Then I should see a delayed-data indicator on the screen
    When I switch to a foreign context exchange/source and click 'Go'
    Then I should see a delayed-data indicator on the screen

  @ui @critical @p0
  Scenario: Index Inquiry is always live for local and EOD data for foreign (as indicated by UI behavior)
    Given I log in with valid call centre credentials through SSO
    And I enter Trading
    When I open 'Market View' > 'Index Watch' and select a local exchange
    And I click 'Refresh'
    Then index values should update consistent with live inquiry behavior
    When I select a foreign exchange/source
    And I click 'Refresh'
    Then the index view should indicate EOD data behavior for foreign context

  @ui @p1
  Scenario: Tax Simulation data is always delayed (as indicated by UI)
    Given I authenticate a customer and enter Trading
    When I open the 'Tax Simulation' module
    Then I should see a delayed-data indicator on the Tax Simulation screen

  @ui @p2
  Scenario: TASE Security Transaction Types list includes Buy, Sell, CA, Security Transfer, Others
    Given I log in with valid call centre credentials through SSO
    When I open the 'TASE Regulations' content section
    Then I should see transaction types including 'Buy'
    And I should see transaction types including 'Sell'
    And I should see transaction types including 'CA'
    And I should see transaction types including 'Security Transfer'
    And I should see transaction types including 'Others'
