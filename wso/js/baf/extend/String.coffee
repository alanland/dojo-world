define ->
  if typeof String.prototype.startsWith != 'function'
    String.prototype.startsWith = (str)->
      return str.length > 0 && this.substring(0, str.length) == str;

  if  typeof String.prototype.endsWith != 'function'
    String.prototype.endsWith = (str)->
      return str.length > 0 && this.substring(this.length - str.length, this.length) == str;