#####
# NetCDF-C Continuous Integration
# Some Test/System Setup
#####
set (CTEST_PROJECT_NAME "netcdf-c")

set(CTEST_NIGHTLY_START_TIME "00:00:00 EST")
set(CTEST_SITE "CDash")

set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "my.cdash.org")
set(CTEST_DROP_LOCATION "/submit.php?project=${CTEST_PROJECT_NAME}")
set(CTEST_DROP_SITE_CDASH TRUE)


# Get Hostname
find_program(HOSTNAME_CMD NAMES hostname)
exec_program(${HOSTNAME_CMD} OUTPUT_VARIABLE HOSTNAME)
set(CTEST_SITE "${HOSTNAME}")

# Get system configuration
find_program(UNAME NAMES uname)
IF(UNAME)
 macro(getuname name flag)
   exec_program("${UNAME}" ARGS "${flag}" OUTPUT_VARIABLE "${name}")
 endmacro(getuname)
 getuname(osname -s)
 getuname(osrel  -r)
 getuname(cpu    -m)
 IF(NOT CTEST_BUILD_NAME)
  set(CTEST_BUILD_NAME        "${osname}-${osrel}-${cpu}")
 ENDIF()
ENDIF()


# Determine unique identifier to append.
exec_program("date" ARGS "+%s" OUTPUT_VARIABLE "TIME_IDENTIFIER")


# Set locations of src/build
set (CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}/Dashboards")
SET (CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_PROJECT_NAME}-src-${TIME_IDENTIFIER}")
SET (CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_PROJECT_NAME}-build-cont-${TIME_IDENTIFIER}")

set(ENV{LC_ALL} C)
SET (CTEST_BACKUP_AND_RESTORE TRUE)


####
# End Test/System Setup
#####

IF(MSVC)
	SET(CMAKE_GENERATOR "Visual Studio 10 Win64")
ELSE()
	set (CTEST_CMAKE_GENERATOR "Unix Makefiles")
ENDIF()

FIND_PROGRAM(GITNAMES NAMES git)

set (CTEST_GIT_COMMAND "${GITNAMES}")
set (CTEST_COMMAND "\"${CTEST_EXECUTABLE_NAME}\" -D Continuous")

set (CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone git://github.com/Unidata/${CTEST_PROJECT_NAME} ${CTEST_SOURCE_DIRECTORY}")
set (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")
set (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

## Set CTest Options
set(OPTIONS -DENABLE_EXTRA_TESTS=ON -DENABLE_HDF4=ON -DENABLE_DAP_REMOTE_TESTS=ON -DENABLE_MMAP=ON)

## Kick off the test
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY_ONCE 1)
#ctest_start("Continuous")
set (first_loop 1)
ctest_start("Continuous")

while (${CTEST_ELAPSED_TIME} GREATER -1)
  set (START_TIME ${CTEST_ELAPSED_TIME})
  ctest_update(RETURN_VALUE count)
  message("Count: ${count}")
  IF(NOT EXISTS "/vagran/NOTEST" AND NOT EXISTS "/home/ciuser/NOTESTC")
    if (count GREATER 0 OR first_loop GREATER 0)
      SET(CTEST_BUILD_NAME	"${CTEST_BUILD_NAME}")

      message("Count ${count} > 0, running analysis.")
      ctest_configure(OPTIONS "${OPTIONS}")
      message("Configuring")
      ctest_build()
      message("Building")
      ctest_test()
      message("Testing")
      ctest_submit()
      message("Submitting")
      message("Analysis complete.")
      set(first_loop 0)
    endif()
  ELSE()
    message("-- Lock file /home/ciuser/NOTEST or /home/ciuser/NOTESTC exists. Skipping tests.")
  ENDIF()
  ctest_sleep( ${START_TIME} 60 ${CTEST_ELAPSED_TIME})

endwhile()
