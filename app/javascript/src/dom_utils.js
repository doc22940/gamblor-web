/**
 * @param {HTMLSelectElement} select element to update options
 * @param {Array<Object>} array of objects with { id, value }
 * 
 * @returns {HTMLSelectElement} update select element
 */
export function updatePlayerSelect(select, options) {
  // TODO: rename this to updateSelect (it is generic and used in other files such as games/_new_form.html.erb
  const optionElms = []
  for (let opt of options) {
    const optionEl = document.createElement('option')
    optionEl.setAttribute('value', opt.id)
    optionEl.innerText = opt.name
    optionElms.push(optionEl)
  }

  select.innerHTML = ''

  optionElms.forEach(x => select.append(x))

  return select
}
