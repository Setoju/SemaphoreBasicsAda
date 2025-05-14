with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer;
                      Producer_Count : in Integer; Consumer_Count : in Integer) is
      Storage : List;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      task type Producer_Task_Type(Id : Positive) is
      end Producer_Task_Type;

      task type Consumer_Task_Type(Id : Positive) is
      end Consumer_Task_Type;

      task body Producer_Task_Type is
      begin
         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & i'Img & " from P" & Id'Img);
            Put_Line ("[Producer " & Id'Img & "] Added item " & i'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
         end loop;
      end Producer_Task_Type;

      task body Consumer_Task_Type is
      begin
         for i in 1 .. Item_Numbers loop
            Empty_Storage.Seize;
            Access_Storage.Seize;

            Put_Line ("[Consumer " & Id'Img & "] Took " & First_Element (Storage));

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;

            delay 1.5;
         end loop;
      end Consumer_Task_Type;

      type Producer_Access is access Producer_Task_Type;
      type Consumer_Access is access Consumer_Task_Type;

      type Producer_Array is array (Positive range <>) of Producer_Access;
      type Consumer_Array is array (Positive range <>) of Consumer_Access;

      Producers : Producer_Array(1 .. Producer_Count);
      Consumers : Consumer_Array(1 .. Consumer_Count);

   begin
      for I in Producers'Range loop
         Producers(I) := new Producer_Task_Type(I);
      end loop;

      for I in Consumers'Range loop
         Consumers(I) := new Consumer_Task_Type(I);
      end loop;
   end Starter;

begin
   Starter (3, 5, 2, 2);
end Main;
