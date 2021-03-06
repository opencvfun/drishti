################
### RapidXML ###
################

hunter_add_package(RapidXML)
find_package(RapidXML REQUIRED CONFIG)

##############
### eyexml ###
##############

add_executable(eyexml eyexml.cpp)
target_link_libraries(eyexml drishtisdk cxxopts::cxxopts RapidXML::RapidXML)
set_property(TARGET eyexml PROPERTY FOLDER "app/console")
install(TARGETS eyexml DESTINATION bin)

###################################################
##################### DLIB apps ###################
###################################################

# The default dlib all/source.cpp file uses PNG and JPEG libraries for IO
if(JPEG_FOUND AND PNG_FOUND)

  # dlib >= 19.2 forbids: #include <dlib/all/source.cpp>
  # Here we find the installed source.cpp file and add it explicitly.
  get_target_property(dlib_dir dlib::dlib INTERFACE_INCLUDE_DIRECTORIES)
  find_file(dlib_source_cpp "dlib/all/source.cpp" "${dlib_dir}")

  ############################
  ### test_shape_predictor ###
  ############################

  add_executable(test_shape_predictor test_shape_predictor.cpp "${dlib_source_cpp}")
  target_link_libraries(test_shape_predictor drishtisdk cxxopts::cxxopts PNG::png)
  target_compile_definitions(test_shape_predictor PUBLIC DLIB_PNG_SUPPORT DLIB_NO_GUI_SUPPORT=1)
  set_property(TARGET test_shape_predictor PROPERTY FOLDER "app/console")
  install(TARGETS test_shape_predictor DESTINATION bin)

  #############################
  ### train_shape_predictor ###
  #############################

  if(NOT DRISHTI_BUILD_MIN_SIZE)
    add_executable(train_shape_predictor train_shape_predictor.cpp "${dlib_source_cpp}")
    target_link_libraries(train_shape_predictor drishtisdk cxxopts::cxxopts PNG::png)
    target_compile_definitions(train_shape_predictor PUBLIC DLIB_PNG_SUPPORT DLIB_NO_GUI_SUPPORT=1)
    set_property(TARGET train_shape_predictor PROPERTY FOLDER "app/console")
    install(TARGETS train_shape_predictor DESTINATION bin)

    if(DRISHTI_BUILD_TESTS AND NOT (IOS OR ANDROID))
      set(eye_src_model_private "${assets_dir}/images/2318-eye_private.json")
      set(eye_src_image_private "${assets_dir}/images/2318-eye.png")
      set(eye_src_model "${CMAKE_CURRENT_BINARY_DIR}/2318-eye.json")
      set(eye_src_image "${CMAKE_CURRENT_BINARY_DIR}/2318-eye.png")
      set(eye_src_train_xml "${CMAKE_CURRENT_BINARY_DIR}/eye_train.xml")

      set(eye_out_model "${CMAKE_CURRENT_BINARY_DIR}/eye.pba.z")

      # Rename + copy image + model file side-by-side to meet eyexml requirements:
      #
      # dir/some_eye_0.png
      # dir/some_eye_0.xml
      # dir/some_eye_1.png
      # dir/some_eye_1.xml
      # ...

      configure_file("${eye_src_model_private}" "${eye_src_model}" COPYONLY)
      configure_file("${eye_src_image_private}" "${eye_src_image}" COPYONLY)

      # HOST build train + test
      add_test(
        NAME
        "eye_model_preprocess"
        COMMAND
        "eyexml"
        "--input=${eye_src_image}"
        "--output=${eye_src_train_xml}"
        "--extension=.json"
        )

      add_test(
        NAME
        "eye_model_train"
        COMMAND
        "train_shape_predictor"
        "--depth=2"
        "--cascades=3"
        "--dimensions=2,4,6"
        "--train=${eye_src_train_xml}"
        "--model=${eye_out_model}"
        "--silent"        
        )

      add_test(
        NAME
        "eye_model_test"
        COMMAND
        "test_shape_predictor"
        "--input=${eye_src_train_xml}"
        "--model=${eye_out_model}"
        )

    endif()
  endif()
endif()
