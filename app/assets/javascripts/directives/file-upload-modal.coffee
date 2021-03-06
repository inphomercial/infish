angular.module('infish').directive 'fileUploadModal', ($timeout) ->
  templateUrl: 'file-upload-modal.html'
  controller: ($scope) ->
    modalOpen = false

    $scope.ifShowModal = -> modalOpen
    $scope.showModal = -> modalOpen = true
    $scope.closeModal = -> modalOpen = false
    $scope.toggleModal = -> modalOpen = !modalOpen


    addToForm = (statesText, question, answers) ->
      states = []
      states.push (statesText[i] == '1') for i in [0..statesText.length]

      $scope.addNewFilledQuestion(question, answers, states)
      $scope.$apply()

    parseFile = (content) ->
      statesQuestionRegex = /// ^ #begin of line
        X(\d+)[\r\n]{1,2}
        [\d.\s\t]*(.*)[\r\n\t\s]+
         ///i
      lineSplitRegex = /[^\r\n]+/g

      statesQuestionResult = content.match statesQuestionRegex
      question = statesQuestionResult[2]
      statesText = statesQuestionResult[1]

      answers = content.match(lineSplitRegex).slice(2).map (item) ->
        item.replace(/[(]{0,1}[a-j]{1}[\.);]/i, "").trim()

      addToForm statesText, question, answers if statesQuestionResult && answers.length == statesText.length


    loadFile = (file) ->
      return if file.type != "text/plain"

      reader = new FileReader()
      reader.onload = (e) ->
        codes = new Uint8Array(e.target.result)
        encoding = jschardet.detect(codes).encoding
        if encoding == "ascii"
          encoding = "CP1250"

        decoder = new TextDecoder(encoding)
        parseFile decoder.decode(codes)

      reader.readAsArrayBuffer(file);

    $scope.sendFiles = () ->
      fileHandle = document.getElementById('file')
      loadFile f for f in fileHandle.files
      fileHandle.value = ""
      modalOpen = false
