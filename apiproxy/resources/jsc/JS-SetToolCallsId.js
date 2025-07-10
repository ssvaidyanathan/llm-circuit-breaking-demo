//  Copyright 2025 Google LLC
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//       http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

var secResponseObj = JSON.parse(context.getVariable("secondary_response.content"));
var responseObj = JSON.parse(context.getVariable("response.content"));

if(secResponseObj!=null) //response via Service Callout
  toolResponse(secResponseObj, true);
else
  toolResponse(responseObj, false);

function toolResponse(obj, bool){
  if(obj!=null && obj.choices !=null && obj.choices.length!=null && obj.choices.length>=1){
    if (obj.choices[0]!=null && obj.choices[0].finish_reason == "tool_calls" && obj.choices[0].message!=null && obj.choices[0].message.tool_calls!=null && obj.choices[0].message.tool_calls.length!=null &&  obj.choices[0].message.tool_calls.length>=1){
      if(obj.choices[0].message.tool_calls[0].id == null || obj.choices[0].message.tool_calls[0].id == ""){
        obj.choices[0].message.tool_calls[0].id = context.getVariable("messageid");
        print(JSON.stringify(obj));
        context.setVariable("secondary_response.content", JSON.stringify(obj));
        context.setVariable("response.content", JSON.stringify(obj));
        if (bool)
          context.setVariable("error.content", JSON.stringify(obj));
      }else{
        print("id is not null" + obj.choices[0].message.tool_calls[0].id);
      }
    }
  }
}