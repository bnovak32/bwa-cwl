
/**
 * Remove file endings (anything after first "."), illegal characters 
 * (whitespace, hyphen, period), and "_R1" and "_R2" from filenames.
 * @param {String} name - the input filename 
 * @returns {String} a clean version of the filename
 */
function clean(name) {
    return name.split(".")[0].replace(/[^\w\-_\.]/, "_").replace(/_R[12]_/, "_");
};

/**
 * Finds the common characters in two input filenames and creates a common
 * name that can be used to name an output file generated from these two files.
 * @param {String} input1 First filename
 * @param {String} input2 Second filename
 * @returns {String} A string composed of the common characters in input1 
 *                   and input2
 */
function generate_common_name(input1, input2) {
    var input_name1 = clean(input1);
    if (input2 === null) {
        return input_name1;
    }
    var input_name2 = clean(input2);
    var common_prefix = "";
    for (var index = 0; index < input_name1.length; index++) {
        if (input_name1.charAt(index) == input_name2.charAt(index)) {
            common_prefix += input_name1.charAt(index);
        }
    }
    if (common_prefix.length > 3) {
        return common_prefix;
    }
    return input_name1;
};
  
/**
 * Generates a unique ID based on the filename. Relies on the Illumina style
 * of filenaming ({sampleId}_{sampleindex_id}_{flowcell_lane}_R[12]_{filesplit})
 * @param {String} input1 
 * @returns 
 */
function generate_rgid(input1) {
    var id = clean(input1)
    return id.substring(id.indexOf("_")+1);
};

/**
 * Generates a read group dictionary (for populating the ReadGroupType record)
 * using the provided name to generate a unique ID.
 * @param {String} name 
 * @param {String} platform 
 * @returns 
 */
function read_group_values(name, platform) {
    var read_group = {};
    var rg_id = generate_rgid(name);
    read_group["sample"] = rg_id;
    read_group["identifier"] = rg_id;
    read_group["platform"] = platform;
    read_group["library"] = rg_id;
    return read_group;
};