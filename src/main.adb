with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Total_Items : in Integer;
                      Producer_Count : in Integer; Consumer_Count : in Integer) is
      Storage : List;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      Protected type Item_Manager_Type is
         procedure Increment;
         function Next_Item return Integer;
      private
         Counter : Integer := 0;
      end Item_Manager_Type;

      Protected Body Item_Manager_Type is
         procedure Increment is
         begin
            Counter := Counter + 1;
         end Increment;

         function Next_Item return Integer is
         begin
            return Counter + 1;
         end Next_Item;
      end Item_Manager_Type;

      Item_Manager : Item_Manager_Type;

      task type Producer_Task_Type(Id : Positive; Items_To_Produce : Natural) is
      end Producer_Task_Type;

      task body Producer_Task_Type is
         Item_Num : Integer;
      begin
         for I in 1 .. Items_To_Produce loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Item_Num := Item_Manager.Next_Item;
            Storage.Append ("item " & Item_Num'Img & " from P" & Id'Img);
            Put_Line ("[Producer " & Id'Img & "] Added item " & Item_Num'Img);
            Item_Manager.Increment;

            Access_Storage.Release;
            Empty_Storage.Release;
         end loop;
      end Producer_Task_Type;

      task type Consumer_Task_Type(Id : Positive; Items_To_Consume : Natural) is
      end Consumer_Task_Type;

      task body Consumer_Task_Type is
      begin
         for I in 1 .. Items_To_Consume loop
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

      Items_Per_Producer : Integer := Total_Items / Producer_Count;
      Items_Per_Consumer : Integer := Total_Items / Consumer_Count;

   begin
      for I in Producers'Range loop
         Producers(I) := new Producer_Task_Type(I, (if I = Producer_Count then Total_Items - Items_Per_Producer * (Producer_Count - 1)
                                                   else Items_Per_Producer) );
      end loop;

      for I in Consumers'Range loop
         Consumers(I) := new Consumer_Task_Type(I, (if I = Consumer_Count then Total_Items - Items_Per_Consumer * (Consumer_Count - 1)
                                                   else Items_Per_Consumer) );
      end loop;
   end Starter;

begin
   Starter (3, 21, 2, 4);
end Main;
