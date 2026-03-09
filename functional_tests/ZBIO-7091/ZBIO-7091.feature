Feature: Postman Test Execution with File Operations and Error Handling
  As a QA engineer
  I want to validate Postman test execution workflows with comprehensive file operations
  So that the system handles various failure scenarios gracefully and maintains data integrity

  Background:
    Given the Postman test execution environment is configured
    And the target base directory "/var/tmp/Roost/RoostGPT/" exists
    And the GitOps integration is configured for "Roost poc"

  @api @file-operations
  Scenario Outline: File copy operations with missing source files
    Given the trigger ID is "<trigger_id>"
    And the target directory structure should be "/var/tmp/Roost/RoostGPT/postman_golang_test-2/<trigger_id>/executor/postman_reports"
    And the source file "<source_file>" <file_status>
    When I execute the Postman test workflow
    And I attempt to create the target directory structure
    And I attempt to copy "<source_file>" to the target directory
    Then the operation should result in "<result_status>"
    And the system should log "<log_level>" message containing "<log_message>"
    And the timeout ID "<timeout_id>" should be <timeout_action>
    And the GitOps cleanup should be <cleanup_status>

    Examples:
      | trigger_id                           | source_file            | file_status    | result_status | log_level | log_message                                    | timeout_id | timeout_action | cleanup_status |
      | d3b3aa55-413e-459c-b7e1-4d82011f5822 | postman_results.html   | does not exist | failure       | ERROR     | Error copying file from postman_results.html  | 220        | cleared        | deferred       |
      | a1b2c3d4-e5f6-7890-abcd-123456789012 | postman_results.html   | does not exist | failure       | ERROR     | Source file does not exist                     | 221        | cleared        | deferred       |
      | f7e8d9c0-b1a2-3456-789a-bcdef0123456 | report_output.html     | does not exist | failure       | ERROR     | Error copying file from report_output.html    | 222        | cleared        | deferred       |

  @api @directory-operations
  Scenario Outline: Directory creation under various conditions
    Given the trigger ID is "<trigger_id>"
    And the base directory has "<permission_level>" permissions
    And the disk space available is "<disk_space>"
    When I attempt to create directory "/var/tmp/Roost/RoostGPT/postman_golang_test-2/<trigger_id>/executor/postman_reports"
    Then the directory creation should "<creation_result>"
    And the system should log "<log_level>" message
    And the operation should handle "<error_type>" appropriately

    Examples:
      | trigger_id                           | permission_level | disk_space | creation_result | log_level | error_type           |
      | d3b3aa55-413e-459c-b7e1-4d82011f5822 | read-write      | sufficient | succeed         | DEBUG     | none                 |
      | a1b2c3d4-e5f6-7890-abcd-123456789012 | read-only       | sufficient | fail            | ERROR     | permission_denied    |
      | f7e8d9c0-b1a2-3456-789a-bcdef0123456 | read-write      | insufficient | fail          | ERROR     | disk_space_full      |
      | b4c5d6e7-f8a9-0123-456b-cdef78901234 | no-access       | sufficient | fail            | ERROR     | access_denied        |

  @api @concurrent-operations
  Scenario Outline: Concurrent test execution with multiple trigger IDs
    Given multiple Postman test executions are initiated with trigger IDs "<trigger_id_1>", "<trigger_id_2>", and "<trigger_id_3>"
    And source file availability is "<file_status_1>", "<file_status_2>", and "<file_status_3>" respectively
    When all three executions run concurrently
    And each attempts to create its respective directory structure
    And each attempts file copy operations
    Then execution "<execution_1>" should "<result_1>"
    And execution "<execution_2>" should "<result_2>"
    And execution "<execution_3>" should "<result_3>"
    And no cross-instance interference should occur
    And all timeout IDs should be cleared independently

    Examples:
      | trigger_id_1                         | trigger_id_2                         | trigger_id_3                         | file_status_1 | file_status_2 | file_status_3 | execution_1 | result_1 | execution_2 | result_2 | execution_3 | result_3 |
      | d3b3aa55-413e-459c-b7e1-4d82011f5822 | a1b2c3d4-e5f6-7890-abcd-123456789012 | f7e8d9c0-b1a2-3456-789a-bcdef0123456 | exists        | missing       | missing       | 1           | succeed  | 2           | fail     | 3           | fail     |
      | b4c5d6e7-f8a9-0123-456b-cdef78901234 | e8f9a0b1-c2d3-4567-8901-234567890123 | h5i6j7k8-l9m0-1234-5678-901234567890 | missing       | exists        | exists        | 1           | fail     | 2           | succeed  | 3           | succeed  |

  @api @security-validation
  Scenario Outline: File system security and permission validation
    Given the system is configured with "<security_level>" security settings
    And the target path is "<target_path>"
    And the user context is "<user_role>"
    When I attempt to create directories using the target path
    And I attempt file operations with the given permissions
    Then the system should "<security_action>" the operation
    And security violations should be "<violation_handling>"
    And the system should log "<log_type>" security events

    Examples:
      | security_level | target_path                                                          | user_role    | security_action | violation_handling | log_type |
      | standard       | /var/tmp/Roost/RoostGPT/postman_golang_test-2/valid/executor       | normal_user  | allow           | none               | INFO     |
      | strict         | /var/tmp/Roost/../../../etc/passwd                                   | normal_user  | block           | logged_and_blocked | ERROR    |
      | standard       | /var/tmp/Roost/RoostGPT/postman_golang_test-2/valid/executor       | admin_user   | allow           | none               | INFO     |
      | strict         | /var/tmp/Roost/RoostGPT/postman_golang_test-2/../sensitive         | normal_user  | block           | logged_and_blocked | WARNING  |

  @api @timeout-management
  Scenario Outline: Timeout handling during file system operations
    Given the timeout configuration is set with timeout ID "<timeout_id>"
    And the file operation duration is "<operation_duration>"
    And the timeout threshold is "<timeout_threshold>"
    When I execute file system operations
    And the operation takes "<operation_duration>" to complete
    Then the timeout should be "<timeout_result>"
    And the timeout ID should be "<timeout_action>"
    And the system should "<system_action>"

    Examples:
      | timeout_id | operation_duration | timeout_threshold | timeout_result | timeout_action | system_action                |
      | 220        | 30 seconds        | 60 seconds       | not_exceeded   | cleared        | complete_normally            |
      | 221        | 90 seconds        | 60 seconds       | exceeded       | expired        | terminate_gracefully         |
      | 222        | 45 seconds        | 60 seconds       | not_exceeded   | cleared        | complete_normally            |
      | 223        | 120 seconds       | 60 seconds       | exceeded       | expired        | cleanup_and_terminate        |

  @api @file-validation
  Scenario Outline: Report file validation and corruption handling
    Given a Postman report file "<file_name>" exists
    And the file has "<file_condition>" characteristics
    And the file size is "<file_size>"
    When I attempt to validate the file before copy operation
    And I attempt to copy the file to the target directory
    Then the validation should "<validation_result>"
    And the copy operation should "<copy_result>"
    And the system should log "<log_level>" with message containing "<error_type>"

    Examples:
      | file_name              | file_condition | file_size | validation_result | copy_result | log_level | error_type           |
      | postman_results.html   | valid_html     | 1024 KB   | pass              | succeed     | INFO      | none                 |
      | postman_results.html   | corrupted_html | 512 KB    | fail              | fail        | ERROR     | corruption_detected  |
      | postman_results.html   | zero_bytes     | 0 KB      | fail              | fail        | ERROR     | empty_file           |
      | postman_results.html   | truncated      | 256 KB    | fail              | fail        | WARNING   | incomplete_file      |

  @api @network-storage
  Scenario Outline: Network file system and remote storage operations
    Given the target directory is mounted on "<storage_type>"
    And the network connectivity is "<connectivity_status>"
    And the mount status is "<mount_status>"
    When I attempt directory creation on network storage
    And I attempt file copy operations
    Then the operation should "<operation_result>"
    And the system should handle "<error_type>" appropriately
    And network-specific errors should be "<error_handling>"

    Examples:
      | storage_type | connectivity_status | mount_status | operation_result | error_type              | error_handling |
      | nfs          | stable             | mounted      | succeed          | none                    | none           |
      | nfs          | intermittent       | mounted      | retry            | connectivity_issues     | retry_with_backoff |
      | nfs          | stable             | unmounted    | fail             | mount_failure           | logged_error   |
      | cifs         | unstable           | mounted      | fail             | network_timeout         | timeout_error  |

  @api @resource-management
  Scenario Outline: System resource management during file operations
    Given the system has "<memory_limit>" memory available
    And the file handle limit is "<file_handle_limit>"
    And the current resource usage is "<current_usage>"
    When I execute file operations requiring "<required_resources>"
    Then the operation should "<resource_result>"
    And resource cleanup should be "<cleanup_status>"
    And the system stability should be "<stability_status>"

    Examples:
      | memory_limit | file_handle_limit | current_usage | required_resources | resource_result | cleanup_status | stability_status |
      | 1GB          | 1000             | 50%           | normal             | succeed         | automatic      | stable           |
      | 256MB        | 100              | 90%           | high               | fail            | forced         | stable           |
      | 512MB        | 500              | 95%           | critical           | fail            | automatic      | degraded         |
      | 2GB          | 2000             | 30%           | normal             | succeed         | automatic      | stable           |

  @api @container-environment
  Scenario Outline: Container environment file system operations
    Given the application runs in "<container_type>" container
    And volume mounts are configured for "<mount_points>"
    And container restart capability is "<restart_status>"
    When I execute file operations within the container
    And the container experiences "<container_event>"
    Then file operations should "<operation_result>"
    And file persistence should be "<persistence_status>"
    And container isolation should be "<isolation_status>"

    Examples:
      | container_type | mount_points                    | restart_status | container_event | operation_result | persistence_status | isolation_status |
      | docker         | /var/tmp:/host/tmp             | enabled        | none            | succeed          | maintained         | enforced         |
      | docker         | /var/tmp:/host/tmp             | enabled        | restart         | recover          | maintained         | enforced         |
      | kubernetes     | persistent_volume              | automatic      | pod_restart     | recover          | maintained         | enforced         |
      | docker         | /var/tmp:/host/tmp             | disabled       | crash           | fail             | lost               | enforced         |

  @api @logging-validation
  Scenario Outline: Comprehensive logging system validation
    Given logging is configured with "<log_level>" level
    And the operation type is "<operation_type>"
    And the operation result is "<operation_result>"
    When the system performs the operation
    Then a "<expected_log_level>" log entry should be created
    And the log message should contain "<message_content>"
    And sensitive information should be "<information_handling>"
    And log correlation should be "<correlation_status>"

    Examples:
      | log_level | operation_type       | operation_result | expected_log_level | message_content                    | information_handling | correlation_status |
      | DEBUG     | directory_creation   | success          | DEBUG              | Directory created successfully     | masked               | maintained         |
      | INFO      | test_execution       | success          | INFO               | Test Execution Result [object Object] | masked               | maintained         |
      | ERROR     | file_copy           | failure          | ERROR              | Error copying file from postman_results.html | masked               | maintained         |
      | WARNING   | timeout_clearance   | success          | DEBUG              | Timeout cleared for ID            | masked               | maintained         |

  @api @multi-user-security
  Scenario Outline: Multi-user environment and ownership conflicts
    Given the system has multiple users "<user_1>" and "<user_2>"
    And user "<user_1>" has "<permissions_1>" permissions
    And user "<user_2>" has "<permissions_2>" permissions
    When user "<user_1>" creates directory structure
    And user "<user_2>" attempts to access the same structure
    Then the access should be "<access_result>"
    And ownership conflicts should be "<conflict_resolution>"
    And security boundaries should be "<security_status>"

    Examples:
      | user_1    | user_2    | permissions_1 | permissions_2 | access_result | conflict_resolution | security_status |
      | testuser1 | testuser2 | owner         | group         | allowed       | inherited          | maintained      |
      | testuser1 | testuser2 | owner         | other         | denied        | blocked            | enforced        |
      | root      | testuser1 | admin         | normal        | allowed       | elevated           | maintained      |
      | testuser1 | testuser2 | normal        | normal        | denied        | blocked            | enforced        |

  @api @end-to-end-integration
  Scenario: Complete end-to-end workflow with failure recovery
    Given the Postman test execution is initialized with trigger ID "d3b3aa55-413e-459c-b7e1-4d82011f5822"
    And the Test Execution Result object is prepared
    And the timeout ID is set to "220"
    When I execute the complete Postman test workflow
    And I create the directory structure "/var/tmp/Roost/RoostGPT/postman_golang_test-2/d3b3aa55-413e-459c-b7e1-4d82011f5822/executor/postman_reports"
    And I inject a source file missing scenario for "postman_results.html"
    And I attempt the file copy operation
    Then the directory creation should be logged at DEBUG level
    And the file copy should fail with ERROR level logging containing "Error copying file from postman_results.html to target: Source file does not exist"
    And the timeout ID "220" should be cleared successfully
    And the GitOps cleanup should be deferred with message "GitOps Cleanup is deferred for Roost poc"
    And the system should remain stable for subsequent executions
    And the workflow should support restart capability after failure recovery

  @api @disk-space-management
  Scenario Outline: Disk space exhaustion handling during operations
    Given the target volume has "<available_space>" free space
    And the operation requires "<required_space>" space
    And disk monitoring is "<monitoring_status>"
    When I attempt directory creation and file copy operations
    Then the space validation should "<space_check_result>"
    And the operation should "<operation_outcome>"
    And disk space errors should be "<error_handling>"
    And cleanup should "<cleanup_behavior>"

    Examples:
      | available_space | required_space | monitoring_status | space_check_result | operation_outcome | error_handling    | cleanup_behavior |
      | 1GB             | 100MB         | enabled           | pass               | succeed           | none              | automatic        |
      | 50MB            | 100MB         | enabled           | fail               | abort             | logged_error      | forced           |
      | 500MB           | 450MB         | disabled          | skip               | proceed           | runtime_error     | partial          |
      | 10MB            | 1GB           | enabled           | fail               | abort             | space_error       | automatic        |
