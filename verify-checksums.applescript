--
--  Calculate Checksums
--
--	Drag or select multiple files to calculate md5 and SHA-1 checksums
--	Check if the input matches any of the checksums
--
--  Created by Ben on 01/Aug/2011.
--  Copyright (c) 2011 @bcylin. Released under the MIT License.
--  http://opensource.org/licenses/MIT
--

property md5_digest : {name:"MD5", command:"md5 ", length:32}
property sha1_digest : {name:"SHA-1", command:"openssl sha1 ", length:40}


-- Action on double clicking the icon
on run
	set selected_items to (choose file with multiple selections allowed)
	my calculateDigest(selected_items)
end run


-- Action on dragging files to the icon
on open dragged_items
	my calculateDigest(dragged_items)
end open


-- Calculate both MD5 and SHA-1 checksum and check if the input matches
-- @param {list} of file aliases
on calculateDigest(incoming_list)
	repeat with this_file in incoming_list
		-- set dialog buttons according to the order of the processing file
		if (this_file as string is equal to the last item of incoming_list as string) then
			set button_list to {"Check", "Close"}
		else
			set button_list to {"Check", "Next"}
		end if
		
		tell application "Finder"
			set file_name to name of this_file
			set file_path to quoted form of POSIX path of this_file
		end tell

		-- calculate MD5, grab the result from the end of output
		try
			do shell script (command of md5_digest) & file_path
			set md5 to text -(length of md5_digest) through -1 of result
		on error
			set md5 to "fail to calculate"
		end try

		-- calculate SHA-1, grab the result from the end of output
		try
			do shell script (command of sha1_digest) & file_path
			set sha1 to text -(length of sha1_digest) through -1 of result
		on error
			set sha1 to "fail to calculate"
		end try

		-- set blank dialog returned value
		set matching_result to ""
		set button_clicked to ""
		set user_input to ""

		-- keep checking checksums until user click "Next" or "Close"
		repeat until (button_clicked is "Next" or button_clicked is "Close")
			set the_result to (display dialog Â
				name of md5_digest & ": " & return & md5 & return & return & Â
				name of sha1_digest & ": " & return & sha1 & return & return & Â
				"Paste the checksum blow to check if they match." & return & return & Â
				matching_result default answer user_input Â
				buttons button_list default button "Check" with title file_name)

			-- get user's response
			set button_clicked to button returned of the_result
			set user_input to text returned of the_result

			-- check if the input matches the digests, update the maching result
			if user_input is md5 then
				set matching_result to "The checksum below matches " & name of md5_digest & "."
			else if user_input is sha1 then
				set matching_result to "The checksum below matches " & name of sha1_digest & "."
			else
				set matching_result to "The checksum below does not match."
			end if
		end repeat

		-- go to the next file alias
	end repeat
end calculateDigest