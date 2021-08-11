
---
| No.| Kubectl apply                                                                                                  | Kubectl create                                                                                                | kubectl replace |
| ---| ---                                                                                                            | ---                                                                                                           | ---             |
| 1. | It directly updates in the current live source, only the attributes which are given in the file.               | It first deletes the resources and then creates it from the file provided.                                    | NA              |
| 2. | The file used in apply can be an incomplete spec                                                               | The file used in create should be complete                                                                    | NA              |
| 3. | Apply works only on some properties of the resources                                                           | Create works on every property of the resources                                                               | NA              |
| 4. | You can apply a file that changes only an annotation, without specifying any other properties of the resource. | If you will use the same file with a replace command, the command would fail, due to the missing information. | NA              |
