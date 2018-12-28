module Editing exposing
    ( Editing, getEdited, readPrevious, isUnchanged
    , startEdit, edit, applyEdit
    , Collection, EditingEntry, fromTasksCollection, inlineEdit, toList
    )

{-| Editing of tasks.


# Editing

@docs Editing, getEdited, readPrevious, isUnchanged


# Editing Tasks

@docs startEdit, edit, applyEdit


# Collections

@docs Collection, EditingEntry, fromTasksCollection, inlineEdit, toList

-}

import IdCollection
import Tasks


{-| Obscure type that holds the information of the current edit.
-}
type Editing
    = Editing EditingInfo


{-| The actual data for the current edit.
-}
type alias EditingInfo =
    { edited : String
    , previousAction : Tasks.Action
    }


getEdited : Editing -> String
getEdited (Editing info) =
    info.edited


readPrevious : Editing -> String
readPrevious (Editing info) =
    info.previousAction |> Tasks.stringFromAction


isUnchanged : Editing -> Bool
isUnchanged (Editing info) =
    info.edited == Tasks.stringFromAction info.previousAction


{-| Initiates editing.
-}
startEdit : Tasks.Task -> Editing
startEdit task =
    Editing (initEditingInfo task)


{-| Helper function to initialize the EditingInfo when starting to edit a task.
-}
initEditingInfo : Tasks.Task -> EditingInfo
initEditingInfo task =
    let
        action =
            Tasks.getAction task
    in
    { edited = Tasks.stringFromAction action
    , previousAction = action
    }


{-| Stores the new action in the current edit.
-}
edit : String -> Editing -> Editing
edit newAction (Editing editing) =
    Editing { editing | edited = newAction }


{-| Applies the current edit to the task.
If the edit is valid, the task will be returned.
Otherwise, Nothing is returned.
-}
applyEdit : Editing -> Tasks.Task -> Maybe Tasks.Task
applyEdit (Editing editing) (Tasks.Task task) =
    Tasks.actionFromString editing.edited
        |> Maybe.map
            (\newAction ->
                Tasks.Task { task | action = newAction }
            )



-- TRANSFORM


type alias Collection c =
    IdCollection.IdCollection c EditingEntryInfo


type alias EditingEntry c =
    IdCollection.Entry c EditingEntryInfo


type alias EditingEntryInfo =
    { edit : Maybe Editing
    , task : Tasks.Task
    }


fromTasksCollection : Tasks.Collection c -> Collection c
fromTasksCollection =
    IdCollection.map (\task -> { edit = Nothing, task = task })


inlineEdit : Editing -> Tasks.TaskId c -> Tasks.Collection c -> Collection c
inlineEdit editing id collection =
    fromTasksCollection collection
        |> IdCollection.update id
            (\editTask ->
                { editTask
                    | edit = Just editing
                }
            )


toList =
    IdCollection.toList